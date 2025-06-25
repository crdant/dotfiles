{ config, pkgs, lib, ... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf isLinux {
      enable = true;
      
      allowPing = false;
      
      allowedTCPPorts = [
        22  # SSH (if needed)
      ];
      
      allowedUDPPorts = [ ];
      
      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];
      
      logRefusedConnections = true;
      logRefusedPackets = true;
      logRefusedUnicastsOnly = true;
      
      rejectPackets = true;
      
      extraCommands = ''
        # Drop invalid packets
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
        
        # Rate limiting for SSH
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
        
        # Prevent port scanning
        iptables -N port-scanning
        iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
        iptables -A port-scanning -j DROP
        
        # Drop NULL packets
        iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        
        # Drop XMAS packets
        iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        
        # Drop stealth scan
        iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
        
        # Drop packets with bogus TCP flags
        iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        
        # Protect against SYN flood
        iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
        
        # Log dropped packets
        iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables dropped: " --log-level 7
      '';
      
      extraStopCommands = ''
        # Clean up custom chains
        iptables -F port-scanning 2>/dev/null || true
        iptables -X port-scanning 2>/dev/null || true
      '';
    };
    
    environment.systemPackages = with pkgs; lib.optionals isLinux [
      iptables
      nftables
      ufw
    ];
    
    launchd.daemons = lib.mkIf isDarwin {
      "com.apple.pfctl" = {
        command = "/sbin/pfctl -e -f /etc/pf.conf";
        serviceConfig = {
          Label = "com.apple.pfctl";
          RunAtLoad = true;
          StandardErrorPath = "/var/log/pfctl.log";
          StandardOutPath = "/var/log/pfctl.log";
        };
      };
    };
    
    environment.etc = lib.mkIf isDarwin {
      "pf.anchors/hardening" = {
        text = ''
          # macOS pf firewall rules
          
          # Define macros
          tcp_services = "{ 22 }"
          icmp_types = "{ echoreq unreach }"
          
          # Options
          set block-policy drop
          set loginterface pflog0
          set skip on lo0
          
          # Scrub incoming packets
          scrub in all no-df random-id fragment reassemble
          
          # Block everything by default
          block in log all
          
          # Allow established connections
          pass out quick inet proto tcp from any to any flags any keep state
          pass out quick inet proto udp from any to any keep state
          pass out quick inet proto icmp from any to any keep state
          
          # Allow specific incoming services
          pass in quick inet proto tcp from any to any port $tcp_services flags S/SA keep state
          
          # Block invalid combinations
          block in quick proto tcp flags FIN/FIN
          block in quick proto tcp flags RST/RST
          block in quick proto tcp flags ALL/ALL
          block in quick proto tcp flags NONE/NONE
          block in quick proto tcp flags SYN,FIN/SYN,FIN
          block in quick proto tcp flags SYN,RST/SYN,RST
          
          # Rate limit SSH connections
          pass in quick proto tcp from any to any port 22 flags S/SA keep state (max-src-conn 5, max-src-conn-rate 3/30, overload <bruteforce> flush)
          
          # Block IPs that have been flagged
          table <bruteforce> persist
          block in quick from <bruteforce>
          
          # Allow limited ICMP
          pass in inet proto icmp all icmp-type $icmp_types keep state
          
          # Log blocked packets
          block in log all
        '';
      };
      
      "pf.conf" = lib.mkIf isDarwin {
        text = ''
          # Load hardening anchor
          anchor "hardening"
          load anchor "hardening" from "/etc/pf.anchors/hardening"
          
          # Default system rules
          scrub-anchor "com.apple/*"
          nat-anchor "com.apple/*"
          rdr-anchor "com.apple/*"
          dummynet-anchor "com.apple/*"
          anchor "com.apple/*"
        '';
      };
    };
    
    system.activationScripts.firewall-setup = lib.mkIf isDarwin {
      text = ''
        # Enable packet filter
        /usr/sbin/pfctl -e 2>/dev/null || true
        
        # Load rules
        /usr/sbin/pfctl -f /etc/pf.conf 2>/dev/null || true
      '';
    };
  };
}