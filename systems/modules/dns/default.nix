{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.dnsServerDefaults;
  
  # Use configured values or defaults
  identity = cfg.identity;
  primaryDnsIP = cfg.primaryDnsIP;
  primaryResolverIP = cfg.primaryResolverIP;
  secondaryDnsIP = cfg.secondaryDnsIP; 
  secondaryResolverIP = cfg.secondaryResolverIP; 
  dnsSubnet = cfg.dnsSubnet;
  updateNetworks = cfg.updateNetworks;
  domains = cfg.domains;

in {

  # Configuration Options
  options.services.dnsServerDefaults = {
    identity = mkOption {
      type = types.str;
      default = "shortrib-dns";
      description = "Identity for the DNS server";
    };

    primaryDnsIP = mkOption {
      type = types.str;
      default = "10.105.0.253";
      description = "IP address for the primary DNS server (Knot DNS)";
    };

    primaryResolverIP = mkOption {
      type = types.str;
      default = "10.105.0.252";
      description = "IP address for the primary DNS resolver (Knot Resolver)";
    };

    secondaryDnsIP = mkOption {
      type = types.str;
      default = "10.105.0.251";
      description = "IP address for the secondary DNS server";
    };

    secondaryResolverIP = mkOption {
      type = types.str;
      default = "10.105.0.254";
      description = "IP address for the secondary DNS resolver (Knot Resolver)";
    };

    dnsSubnet = mkOption {
      type = types.str;
      default = "10.105.0.0/24";
      description = "DNS subnet in CIDR notation";
    };

    updateNetworks = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.1" "10.25.0.250/24" ];
      description = "Additional networks allowed for DNS updates";
    };

    domains = mkOption {
      type = types.listOf types.str;
      default = [
        "shortrib.net"
        "lab.shortrib.net"
        "shortrib.app"
        "shortrib.dev"
        "shortrib.run"
      ];
      description = "List of domains to serve";
    };

    acmeEmail = mkOption {
      type = types.str;
      default = "admin@shortrib.net";
      description = "Email address for ACME certificate requests";
    };

    acmeServer = mkOption {
      type = types.str;
      default = "https://certificates.shortrib.run/acme/v02/directory";
      description = "ACME server URL for certificate requests";
    };

    tlsCertDomain = mkOption {
      type = types.str;
      default = "dns.shortrib.net";
      description = "Domain name for TLS certificate";
    };

    tsigKeyPath = mkOption {
      type = types.str;
      default = "/var/lib/knot/tsig-key";
      description = "Path to TSIG key file";
    };
  };

  # Configuration Implementation
  config = {
    environment = {
      systemPackages = with pkgs; [
        coreutils
        openssl
      ];
    };

    # Knot DNS Configuration
    services.knot = {
      enable = true;

      settings = {
        server = {
          identity = identity;
          version = "disabled";
          
          # Listening interfaces
          listen = [
            "${primaryDnsIP}@53"
          ];

          listen-tls = [
            "${primaryDnsIP}@853"
          ];

          cert-file = "/var/lib/acme/${cfg.tlsCertDomain}/fullchain.pem";
          key-file = "/var/lib/acme/${cfg.tlsCertDomain}/key.pem";
        };

        # DNSSEC Policy
        policy = [ 
          {
            id = "automatic-key-management";
            signing-threads = 4 ;
            algorithm = "ECDSAP256SHA256";
            zsk-lifetime = "60d";
          }
        ];

        # Logging Configuration
        log = [{
          target = "syslog";
          any = "info";
        }];

        include = "/etc/knot.conf.d/*.conf";
      };
    };

    # Knot Resolver Configuration
    services.kresd = {
      enable = true;
      
      # Listen on both standard and DoT ports
      listenPlain = [ 
        "${primaryResolverIP}:53"
      ];
      listenTLS = [
        "${primaryResolverIP}:853"
      ];

      # Configuration file
      extraConfig = ''
        -- Enable DNSSEC validation
        modules = {
          'view',     -- View-based configuration
        }

        -- Local zones configuration
        local_zones = {
          ${concatMapStringsSep ",\n          " (d: "'${d}'") domains}
        }

        for _, zone in ipairs(local_zones) do
          -- Create forwarding for each internal zone name
          policy.add(policy.suffix(policy.STUB('${primaryDnsIP}'), {todname(zone)}))
        end

        -- Validate DNSSEC
        policy.add(policy.all(policy.VALIDATE))

        -- Use root hints for recursive resolution
        modules.load('hints')
        hints.root({
          ['.'] = '${pkgs.knot-resolver}/share/knot-resolver/root.hints'
        })
      '';
    };

    # Persistent Zone Management
    system.activationScripts = {
      writeDnsConfig = ''
        # Get runtime information
        config=/etc/knot.conf.d/octodns.conf
        octodns_key=$(${pkgs.openssl}/bin/openssl rand -base64 32)

        mkdir -p $(${pkgs.coreutils}/bin/dirname ''${config})
        
        # Write YAML with runtime values
        cat > ''${config} << EOF
        key:
        - id: octodns.shortrib.net
          algorithm: hmac-sha256
          secret: ''${octodns_key}
        
        acl:
        - id: update-acl
          key: octodns.shortrib.net
          action: update
          action: transfer
        EOF
        
        # Add addresses from Nix variables
        ${lib.concatMapStrings (addr: ''
          echo "  address: ${addr}" >> ''${config}
        '') ([ dnsSubnet ] ++ updateNetworks)}
      '';

      writeZonesConfig = let 
        zonesConfig = {
          zone = map (domain: {
            domain = domain;
            file = "/var/lib/knot/zones/${domain}.zone";
            acl = "octodns-access";
            dnssec-signing = "on";
            dnssec-policy = "automatic-key-management";
          }) domains;
        };
      in ''
        config=/etc/knot.conf.d/zones.conf
        mkdir -p $(${pkgs.coreutils}/bin/dirname ''${config})
        echo '${builtins.toJSON zonesConfig}' | ${pkgs.yq-go}/bin/yq --input-format json --output-format yaml > ''${config}
      '';

      prepareDnsZones = ''
        # Ensure zone directory exists
        mkdir -p /var/lib/knot/zones

        # Create initial zone files if they don't exist
        ${concatMapStrings (domain: ''
          if [ ! -f "/var/lib/knot/zones/${domain}.zone" ]; then
            cat > "/var/lib/knot/zones/${domain}.zone" << EOL
  \$ORIGIN ${domain}.
  \$TTL 3600

  @ IN SOA ns1.${domain}. admin.${domain}. (
      $(date +%Y%m%d01) ; Serial
      3600       ; Refresh
      1800       ; Retry
      604800     ; Expire
      86400 )    ; Minimum TTL

  @           IN NS       ns1.${domain}.
  @           IN NS       ns2.${domain}.

  ns1         IN A        ${primaryDnsIP}
  ns2         IN A        ${secondaryDnsIP}
  EOL
            chmod 660 "/var/lib/knot/zones/${domain}.zone"
            chown knot:knot "/var/lib/knot/zones/${domain}.zone"
          fi
        '') domains}
      '';
    };

    # ACME Configuration
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = cfg.acmeEmail;
        server = cfg.acmeServer;
        listenHTTP = ":80";
      };

      certs."${cfg.tlsCertDomain}" = {
        group = "knot";
        extraDomainNames = [ 
          "ns.shortrib.net"
          "swan.lab.shortrib.net"
          "lyne.lab.shortrib.net"
        ];
      };
    };

    # Firewall Configuration
    networking.firewall = {
      allowedTCPPorts = [ 53 853 ];
      allowedUDPPorts = [ 53 853 ];
    };

  };
}
