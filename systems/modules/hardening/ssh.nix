{ config, pkgs, lib, options, ... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # a bit of a hack, uses the `boot` attribute which we know is linux specific
  nixManagedSsh = builtins.hasAttr "boot" options.services;
  opensshConfig = lib.optionalAttrs nixManagedSsh {
    services.openssh = {
      enable = true;
      
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PermitEmptyPasswords = false;
        ChallengeResponseAuthentication = false;
        KbdInteractiveAuthentication = false;
        UsePAM = true;
        
        X11Forwarding = false;
        PrintMotd = false;
        PrintLastLog = true;
        TCPKeepAlive = true;
        
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        
        MaxAuthTries = 3;
        MaxSessions = 2;
        
        Protocol = 2;
        LogLevel = "VERBOSE";
        
        StrictModes = true;
        IgnoreRhosts = true;
        HostbasedAuthentication = false;
        
        AllowUsers = null;
        AllowGroups = null;
        DenyUsers = null;
        DenyGroups = null;
      };
      
      extraConfig = ''
        # Key exchange algorithms - using strong, modern algorithms
        KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
        
        # Host key algorithms
        HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com
        
        # Ciphers - in order of preference
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
        
        # MACs - using Encrypt-then-MAC
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
        
        # Login grace time
        LoginGraceTime 30s
        
        # Disable compression
        Compression no
        
        # Use privilege separation
        UsePrivilegeSeparation sandbox
        
        # Disable .rhosts files
        IgnoreUserKnownHosts yes
        
        # Verify hostname matches IP
        UseDNS yes
      '';
      
      hostKeys = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
  };

  supportsLaunchd = builtins.hasAttr "launchd" options;
  launchdConfig = lib.optionalAttrs supportsLaunchd {
    launchd.daemons = {
      "com.openssh.sshd" = {
        command = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config";
        serviceConfig = {
          Label = "com.openssh.sshd";
          Disabled = true;
          RunAtLoad = false;
        };
      };
    };
  };

  # a bit of a hack, uses the `defaults` attribute which we know is darwin specific
  # to handle some darwin-specific /etc config
  darwinManagedSsh = builtins.hasAttr "defaults" options.environment;
  darwinSshConfig = lib.optionalAttrs darwinManagedSsh {
    environment.etc = {
      "ssh/sshd_config" = {
        text = ''
          # SSH Server configuration for macOS
          Port 22
          Protocol 2
          
          # Host keys
          HostKey /etc/ssh/ssh_host_ed25519_key
          HostKey /etc/ssh/ssh_host_rsa_key
          
          # Authentication
          PermitRootLogin no
          PubkeyAuthentication yes
          PasswordAuthentication no
          PermitEmptyPasswords no
          ChallengeResponseAuthentication no
          UsePAM yes
          
          # Security
          StrictModes yes
          IgnoreRhosts yes
          HostbasedAuthentication no
          X11Forwarding no
          PrintMotd no
          TCPKeepAlive yes
          
          # Timeouts
          ClientAliveInterval 300
          ClientAliveCountMax 2
          LoginGraceTime 30s
          MaxAuthTries 3
          MaxSessions 2
          
          # Logging
          LogLevel VERBOSE
          SyslogFacility AUTH
          
          # Key exchange algorithms
          KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
          
          # Ciphers
          Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
          
          # MACs
          MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
          
          # Host key algorithms
          HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com
          
          # Other security settings
          Compression no
          UseDNS yes
          PermitUserEnvironment no
          AllowAgentForwarding no
          AllowTcpForwarding no
          GatewayPorts no
          PermitTunnel no
        '';
      };
    };
  };

in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    opensshConfig
    launchdConfig
    darwinSshConfig
    (lib.optionalAttrs darwinManagedSsh {
      system.activationScripts.ssh-host-keys = {
        text = ''
          # Generate SSH host keys if they don't exist
          if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
          fi
          if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
          fi
          
          # Remove weak host keys
          rm -f /etc/ssh/ssh_host_dsa_key* /etc/ssh/ssh_host_ecdsa_key*
          
          # Set proper permissions
          chmod 600 /etc/ssh/ssh_host_*_key
          chmod 644 /etc/ssh/ssh_host_*_key.pub
        '';
      };
    })
  ]);
}
