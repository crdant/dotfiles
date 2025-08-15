{ inputs, outputs, pkgs, lib, options, ... }: 
{
  # Generate Ed25519 DNSSEC key on activation
  system.activationScripts.hickory-dnssec-key = {
    text = ''
      mkdir -p /etc/hickory/dnssec
      
      if [ ! -f /etc/hickory/dnssec/ed25519.p8 ]; then
        ${pkgs.openssl}/bin/openssl genpkey \
          -algorithm Ed25519 \
          -pkcs8 \
          -out /etc/hickory/dnssec/ed25519.p8
        
        chmod 600 /etc/hickory/dnssec/ed25519.p8
        chown hickory-dns:hickory-dns /etc/hickory/dnssec/ed25519.p8
        
        echo "Generated new Ed25519 DNSSEC key for Hickory DNS"
      fi
    '';
    deps = [ "users" ];
  };

  # Create the Hickory DNS configuration
  environment.etc."hickory/hickory-dns.toml" = {
    text = 
      let
        # Your internal zones
        internalZones = [
          "lab.shortrib.net"
          "shortrib.app" 
          "shortrib.dev"
          "shortrib.run"
        ];

        # Common SOA settings
        commonSOA = {
          serial = 2024081401;
          refresh = 1800;
          retry = 300;
          expire = 86400;
          minimum = 60;  # Good for quick DNSSEC recovery
        };

        # Generate TOML for internal zone with DNSSEC
        internalZoneToml = zone: ''
          [[zones]]
          zone = "${zone}"
          zone_type = "Primary"

          [zones.stores]
          type = "sqlite"
          zone_path = "${zone}.zone"
          journal_path = "${zone}_dnssec_update.jrnl"
          allow_update = true

          [zones.dnssec]
          key = "/etc/hickory/dnssec/ed25519.p8"
          algorithm = "ED25519"

          [zones.soa]
          serial = ${toString commonSOA.serial}
          refresh = ${toString commonSOA.refresh}
          retry = ${toString commonSOA.retry}
          expire = ${toString commonSOA.expire}
          minimum = ${toString commonSOA.minimum}

        '';

        # Generate all internal zones
        allInternalZones = builtins.concatStringsSep "\n" (map internalZoneToml internalZones);

      in ''
        # Server settings
        listen_addrs_ipv4 = ["0.0.0.0:53"]
        listen_addrs_ipv6 = ["[::]:53"]

        # Default zones (required, no DNSSEC)
        [[zones]]
        zone = "localhost"
        zone_type = "Primary"
        file = "default/localhost.zone"

        [[zones]]
        zone = "0.0.127.in-addr.arpa"
        zone_type = "Primary"
        file = "default/127.0.0.1.zone"

        [[zones]]
        zone = "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa"
        zone_type = "Primary"
        file = "default/ipv6_1.zone"

        [[zones]]
        zone = "255.in-addr.arpa"
        zone_type = "Primary"
        file = "default/255.zone"

        [[zones]]
        zone = "0.in-addr.arpa"
        zone_type = "Primary"
        file = "default/0.zone"

        # Internal zones with DNSSEC (templated)
        ${allInternalZones}

        # External recursive resolver
        [[zones]]
        zone = "."
        zone_type = "External"

        [zones.stores]
        type = "recursor"
        roots = "default/root.zone"
        ns_cache_size = 1024
        response_cache_size = 1048576
        recursion_limit = 24
        ns_recursion_limit = 24

        allow_server = ["127.0.0.254/32"]
        deny_server = ["0.0.0.0/8", "127.0.0.0/8", "::/128", "::1/128"]

        [zones.stores.cache_policy.default]
        positive_max_ttl = 86400

        [zones.stores.cache_policy.A]
        positive_max_ttl = 3600

        [zones.stores.cache_policy.AAAA]
        positive_max_ttl = 3600
      '';
  };

  # Ensure hickory-dns user exists
  users.users.hickory-dns = {
    isSystemUser = true;
    group = "hickory-dns";
    description = "Hickory DNS server user";
  };
  
  users.groups.hickory-dns = {};

  # Enable and configure the service
  services.hickory-dns = {
    enable = true;
    # Point to your generated config
    configFile = "/etc/hickory/hickory-dns.toml";
    settings = {
      directory = "/etc/hickory/zones";
    };
  };
}
