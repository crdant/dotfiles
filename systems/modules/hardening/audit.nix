{ config, pkgs, lib, options, ... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  supportAuditd = builtins.hasAttr "auditd" options.services;
  auditdConfig = lib.optionalAttrs supportAuditd {
    auditd = {
      enable = true;
      
      rules = [
        # Delete all existing rules
        "-D"
        
        # Buffer size
        "-b 8192"
        
        # Failure mode (1 = printk, 2 = panic)
        "-f 1"
        
        # Monitor sudoers changes
        "-w /etc/sudoers -p wa -k sudo_changes"
        "-w /etc/sudoers.d/ -p wa -k sudo_changes"
        
        # Monitor user/group changes
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        
        # Monitor SSH configuration
        "-w /etc/ssh/sshd_config -p wa -k sshd_config"
        
        # Monitor system authentication
        "-w /etc/pam.d/ -p wa -k pam"
        "-w /etc/security/ -p wa -k security"
        
        # Monitor login/logout events
        "-w /var/log/faillog -p wa -k logins"
        "-w /var/log/lastlog -p wa -k logins"
        "-w /var/log/tallylog -p wa -k logins"
        
        # Monitor cron
        "-w /etc/cron.allow -p wa -k cron"
        "-w /etc/cron.deny -p wa -k cron"
        "-w /etc/cron.d/ -p wa -k cron"
        "-w /etc/cron.daily/ -p wa -k cron"
        "-w /etc/cron.hourly/ -p wa -k cron"
        "-w /etc/cron.monthly/ -p wa -k cron"
        "-w /etc/cron.weekly/ -p wa -k cron"
        "-w /etc/crontab -p wa -k cron"
        "-w /var/spool/cron/ -p wa -k cron"
        
        # Monitor kernel modules
        "-w /sbin/insmod -p x -k modules"
        "-w /sbin/rmmod -p x -k modules"
        "-w /sbin/modprobe -p x -k modules"
        "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
        
        # Monitor mount operations
        "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
        "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
        
        # Monitor file deletion
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
        "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
        
        # Monitor admin actions
        "-w /var/log/sudo.log -p wa -k sudo_log"
        
        # Monitor network configuration
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications"
        "-w /etc/hosts -p wa -k network_modifications"
        "-w /etc/network/ -p wa -k network_modifications"
        
        # Monitor SELinux/AppArmor events
        "-w /etc/selinux/ -p wa -k mac_policy"
        "-w /etc/apparmor/ -p wa -k mac_policy"
        "-w /etc/apparmor.d/ -p wa -k mac_policy"
        
        # Monitor use of privileged commands
        "-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd"
        "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-sudo"
        "-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-su"
        
        # Make configuration immutable
        "-e 2"
      ];
    };
  };

  supportRsyslog = builtins.hasAttr "rsyslog" options.services;
  rsyslogConfig = lib.optionalAttrs supportRsyslog {
    rsyslog = {
      enable = true;
      
      extraConfig = ''
        # Enhanced logging configuration
        
        # Log authentication messages
        auth,authpriv.*                 /var/log/auth.log
        
        # Log all kernel messages
        kern.*                          /var/log/kern.log
        
        # Log anything of level info or higher
        *.info;mail.none;authpriv.none;cron.none  /var/log/messages
        
        # Log cron
        cron.*                          /var/log/cron.log
        
        # Log mail
        mail.*                          -/var/log/mail.log
        
        # Emergency messages
        *.emerg                         :omusrmsg:*
        
        # Forward logs to central syslog server (if configured)
        # *.* @@remote-syslog-server:514
        
        # Log rotate configuration
        $FileCreateMode 0640
        $DirCreateMode 0755
        $Umask 0022
        
        # Disable rate limiting
        $SystemLogRateLimitInterval 0
        $SystemLogRateLimitBurst 0
      '';
    };
  };

  supportsFail2ban = builtins.hasAttr "fail2ban" options.services;
  fail2banConfig = lib.optionalAttrs supportsFail2ban {
    fail2ban = {
      enable = true;
      
      jails = {
        ssh-iptables = ''
          enabled = true
          filter = sshd
          action = iptables-multiport[name=SSH, port="ssh", protocol=tcp]
          logpath = /var/log/auth.log
          maxretry = 3
          bantime = 3600
          findtime = 600
        '';
        
        ssh-ddos = ''
          enabled = true
          filter = sshd-ddos
          action = iptables-multiport[name=SSH, port="ssh", protocol=tcp]
          logpath = /var/log/auth.log
          maxretry = 10
          bantime = 3600
          findtime = 60
        '';
      };
    };
  };

  supportsSystemd = builtins.hasAttr "systemd" options.services;
  systemdConfig = lib.optionalAttrs supportsSystemd {
    systemd = {
      service = {
        auditd-configuration = {
          description = "Configure audit rules";
          wantedBy = [ "multi-user.target" ];
          after = [ "auditd.service" ];
          
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.audit}/bin/auditctl -R /etc/audit/audit.rules";
          };
        };
      };
    };
  };

  supportsLaunchd = builtins.hasAttr "launchd" options.services;
  launchdConfig = lib.optionalAttrs supportsLaunchd {
    launchd = {
      daemons = {
        "net.shortrib.lab.audit" = {
          command = "${pkgs.bash}/bin/bash -c 'while true; do /usr/bin/log stream --predicate \"eventMessage contains \\\"Authentication\\\" OR eventMessage contains \\\"sudo\\\" OR eventMessage contains \\\"SSH\\\"\" --info >> /var/log/security-audit.log; sleep 60; done'";
          serviceConfig = {
            Label = "com.hardening.audit";
            RunAtLoad = true;
            KeepAlive = true;
            StandardErrorPath = "/var/log/audit-error.log";
            StandardOutPath = "/var/log/audit.log";
          };
        };
      };
    };
  };

in 
  {
    config = lib.mkIf cfg.enable mkMerge [
      {
        services = mkMerge [
          auditdConfig
          rsyslogConfig
          fail2banConfig
        ];
      
        environment.systemPackages = with pkgs; [
          auditbeat
          filebeat
        ] ++ lib.optionals isLinux [
          audit
          aide
          logwatch
          syslog-ng
        ];

        system.activationScripts.audit-setup = {
          text = ''
            # Create log directories with proper permissions
            mkdir -p /var/log/audit
            chmod 750 /var/log/audit
            
            ${if isLinux then ''
              # Set up audit log rotation
              cat > /etc/logrotate.d/audit << EOF
              /var/log/audit/audit.log {
                  daily
                  rotate 30
                  compress
                  delaycompress
                  missingok
                  notifempty
                  create 0600 root root
                  sharedscripts
                  postrotate
                      /usr/bin/pkill -HUP auditd
                  endscript
              }
              EOF
            '' else ''
              # macOS log setup
              mkdir -p /var/log
              touch /var/log/security-audit.log
              chmod 640 /var/log/security-audit.log
            ''}
            
            # Create fail2ban directory
            mkdir -p /var/log/fail2ban
            chmod 750 /var/log/fail2ban
          '';
        };
        
        environment.etc = lib.mkIf isDarwin {
          "newsyslog.d/security-audit.conf" = {
            text = ''
              # logfilename                      [owner:group]    mode count size when  flags [/pid_file] [sig_num]
              /var/log/security-audit.log                         640  30    *    @T00  J
              /var/log/audit.log                                  640  30    *    @T00  J
              /var/log/audit-error.log                            640  30    *    @T00  J
            '';
          };
        };
    }
    systemdConfig
    launchdConfig
  ];
}      

