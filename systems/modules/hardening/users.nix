{ config, pkgs, lib, options, ... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # a bit of a hack, uses the `boot` attribute which we know is linux specific
  # to handle some linux-specific security config
  linuxManagedSecurity = builtins.hasAttr "boot" options;
  linuxSecurityConfig = lib.optionalAttrs linuxManagedSecurity {
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
        
        extraConfig = ''
          # Hardened sudo configuration
          Defaults        env_reset
          Defaults        mail_badpass
          Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
          Defaults        use_pty
          Defaults        timestamp_timeout=15
          Defaults        passwd_tries=3
          Defaults        logfile="/var/log/sudo.log"
          Defaults        lecture="always"
          Defaults        requiretty
          Defaults        umask=0077
          Defaults        passwd_timeout=1
          
          # Prevent shell escapes
          Defaults        noexec
          Defaults        requiretty
          
          # Log all sudo commands
          Defaults        log_input
          Defaults        log_output
          Defaults        iolog_dir="/var/log/sudo-io"
          
          # Restrict root access
          root            ALL=(ALL:ALL) ALL
          %wheel          ALL=(ALL:ALL) ALL
        '';
      };
      
      pam.services = {
        login = {
          limits = [
            { domain = "*"; type = "soft"; item = "core"; value = "0"; }
            { domain = "*"; type = "hard"; item = "core"; value = "0"; }
            { domain = "*"; type = "hard"; item = "nproc"; value = "1000"; }
            { domain = "*"; type = "hard"; item = "maxlogins"; value = "3"; }
            { domain = "*"; type = "hard"; item = "maxsyslogins"; value = "3"; }
            { domain = "*"; type = "hard"; item = "priority"; value = "10"; }
          ];
        };
        
        sshd = {
          showMotd = true;
          makeHomeDir = false;
        };
      };
      
      loginDefs = {
        PASS_MAX_DAYS = 90;
        PASS_MIN_DAYS = 7;
        PASS_WARN_AGE = 14;
        PASS_MIN_LEN = 14;
        
        UMASK = "077";
        
        ENCRYPT_METHOD = "SHA512";
        SHA_CRYPT_MIN_ROUNDS = 10000;
        
        LOG_UNKFAIL_ENAB = "yes";
        LOG_OK_LOGINS = "yes";
        SYSLOG_SU_ENAB = "yes";
        SYSLOG_SG_ENAB = "yes";
        
        FAILLOG_ENAB = "yes";
        FAIL_DELAY = 4;
        
        CREATE_HOME = "no";
        DEFAULT_HOME = "no";
        
        USERGROUPS_ENAB = "no";
        
        ENV_SUPATH = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        ENV_PATH = "PATH=/usr/local/bin:/usr/bin:/bin";
      };
    };
  };

  linuxUsersConfig = lib.optionalAttrs linuxManagedSecurity {
    users = {
      mutableUsers = false;
      
      users.root = {
        hashedPassword = "!";  # Disable root password
      };
    };
  };

  # a bit of a hack, uses the `defaults` attribute which we know is darwin specific
  # to handle some darwin-specific /etc config
  darwinManagedPam = builtins.hasAttr "defaults" options.environment;
  darwinPamConfig = lib.optionalAttrs darwinManagedPam {
    environment.etc = {
      "pam.d/sudo_local" = {
        text = ''
          # sudo_local: local config file which survives system updates
          auth       sufficient     pam_smartcard.so
          auth       required       pam_opendirectory.so
          account    required       pam_permit.so
          password   required       pam_deny.so
          session    required       pam_permit.so
        '';
      };
    };
  };

in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    linuxSecurityConfig
    linuxUsersConfig
    darwinPamConfig
    {
      environment.systemPackages = with pkgs; [
        pam_u2f
        google-authenticator
      ] ++ lib.optionals isLinux [
        libpwquality
        pam_krb5
      ];
      
      system.activationScripts.user-hardening = {
        text = ''
          # Set secure permissions on user home directories
          ${if isLinux then ''
            find /home -maxdepth 1 -type d -name '[!.]*' -exec chmod 700 {} \; 2>/dev/null || true
          '' else ''
            find /Users -maxdepth 1 -type d -name '[!.]*' -exec chmod 700 {} \; 2>/dev/null || true
          ''}
          
          # Ensure proper ownership of user files
          ${if isLinux then ''
            for user_home in /home/*; do
              if [ -d "$user_home" ]; then
                username=$(basename "$user_home")
                chown -R "$username:$username" "$user_home" 2>/dev/null || true
              fi
            done
          '' else ''
            for user_home in /Users/*; do
              if [ -d "$user_home" ] && [ "$(basename "$user_home")" != "Shared" ]; then
                username=$(basename "$user_home")
                chown -R "$username:staff" "$user_home" 2>/dev/null || true
              fi
            done
          ''}
          
          # Set secure permissions on sensitive files
          chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
          chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null || true
          chmod 644 /etc/passwd 2>/dev/null || true
          chmod 644 /etc/group 2>/dev/null || true
          ${if isLinux then "chmod 640 /etc/shadow 2>/dev/null || true" else ""}
          ${if isLinux then "chmod 640 /etc/gshadow 2>/dev/null || true" else ""}
          
          # Remove unnecessary SUID/SGID bits
          ${if isLinux then ''
            # List of binaries that don't need SUID
            for binary in /usr/bin/rcp /usr/bin/rsh /usr/bin/rlogin; do
              [ -f "$binary" ] && chmod -s "$binary" 2>/dev/null || true
            done
          '' else ""}
          
          # Ensure no users have UID 0 except root
          ${if isLinux then ''
            awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd | while read user; do
              echo "Warning: User $user has UID 0!"
            done
          '' else ""}
          
          # Check for users with empty passwords
          ${if isLinux then ''
            awk -F: '($2 == "") { print $1 }' /etc/shadow | while read user; do
              echo "Warning: User $user has no password!"
            done
          '' else ""}
        '';
      };
    }
  ]);
}
