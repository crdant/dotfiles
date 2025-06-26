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
      services = {
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
        
        aide-check = {
          description = "AIDE file integrity check";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.aide}/bin/aide --check";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };
        
        chkrootkit-scan = {
          description = "Chkrootkit rootkit scan";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.chkrootkit}/bin/chkrootkit";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };
        
        unhide-scan = {
          description = "Unhide hidden process scan";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.unhide}/bin/unhide proc";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };
        
        lynis-audit = {
          description = "Lynis comprehensive security audit";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.lynis}/bin/lynis audit system --cronjob --report-file /var/log/lynis/lynis-report.dat";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
            WorkingDirectory = "/var/log/lynis";
          };
        };
        
        logwatch-report = {
          description = "Logwatch daily security report";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.logwatch}/bin/logwatch --output file --filename /var/log/logwatch/logwatch-report.txt --detail Med --service All --range yesterday";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };
      };
      
      timers = {
        aide-check = {
          description = "Run AIDE file integrity check daily";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = "1h";
            Persistent = true;
          };
        };
        
        chkrootkit-scan = {
          description = "Run chkrootkit scan weekly";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "weekly";
            RandomizedDelaySec = "2h";
            Persistent = true;
          };
        };
        
        unhide-scan = {
          description = "Run unhide scan daily";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = "30m";
            Persistent = true;
          };
        };
        
        lynis-audit = {
          description = "Run Lynis security audit weekly";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "weekly";
            RandomizedDelaySec = "3h";
            Persistent = true;
          };
        };
        
        logwatch-report = {
          description = "Generate daily logwatch security report";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = "2h";
            Persistent = true;
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
    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        services = lib.mkMerge [
          auditdConfig
          rsyslogConfig
          fail2banConfig
        ];
      
        environment.systemPackages = with pkgs; lib.optionals isLinux [
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
              
              # Set up AIDE directories and database
              mkdir -p /var/lib/aide /var/log/aide
              chmod 700 /var/lib/aide
              chmod 755 /var/log/aide
              
              # Initialize AIDE database if it doesn't exist
              if [ ! -f /var/lib/aide/aide.db ]; then
                echo "Initializing AIDE database..."
                ${pkgs.aide}/bin/aide --init
                if [ -f /var/lib/aide/aide.db.new ]; then
                  mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
                fi
              fi
              
              # Set up Lynis directories
              mkdir -p /var/log/lynis /etc/lynis
              chmod 755 /var/log/lynis
              
              # Set up Logwatch directories
              mkdir -p /var/log/logwatch /etc/logwatch/conf /var/cache/logwatch
              chmod 755 /var/log/logwatch
              chmod 755 /var/cache/logwatch
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
        
        environment.etc = lib.mkMerge [
          (lib.optionalAttrs isLinux {
            "lynis/default.prf" = {
              text = ''
                # Lynis security audit configuration
                
                # Skip some checks that might be noisy in containers or specific setups
                skip-test=AUTH-9264  # Check for presence of auditd
                skip-test=AUTH-9266  # Check auditd rules
                skip-test=FILE-6310  # Check for presence of /tmp noexec
                
                # Colors (for non-cronjob runs)
                colors=yes
                
                # Compression
                compressed-uploads=yes
                
                # Reporting
                report-file=/var/log/lynis/lynis-report.dat
                log-file=/var/log/lynis/lynis.log
                
                # Security scan options
                quick=no
                auditor="System Administrator"
                
                # Update check
                update-check=yes
              '';
            };
            
            "logwatch/conf/logwatch.conf" = {
              text = ''
                # Logwatch configuration for security focus
                
                # Output format
                Output = file
                Format = text
                Encode = none
                
                # Detail level (Low, Med, High, or 0-10)
                Detail = Med
                
                # Services to monitor (All, or specific services)
                Service = All
                
                # Log range
                Range = yesterday
                
                # Archive processing
                Archives = Yes
                
                # Host limit (blank for localhost only)
                HostLimit = 
                
                # Mail settings (disabled since we're outputting to file)
                mailer = "/bin/false"
                
                # Temporary directory
                TmpDir = /var/cache/logwatch
                
                # Print hostname in reports
                hostname = yes
                
                # Include environment information
                SplitHosts = No
              '';
            };
            
            "aide/aide.conf" = {
              text = ''
                # AIDE configuration for file integrity monitoring
                
                # Database paths
                database=file:/var/lib/aide/aide.db
                database_out=file:/var/lib/aide/aide.db.new
                gzip_dbout=yes
                
                # Report settings
                verbose=5
                report_url=file:/var/log/aide/aide.log
                report_url=stdout
                
                # Rule definitions
                FIPSR = p+i+n+u+g+s+m+c+acl+selinux+xattrs+sha256
                NORMAL = FIPSR+sha512
                DIR = p+i+n+u+g+acl+selinux+xattrs
                PERMS = p+i+n+u+g+acl+selinux
                LOG = p+u+g+n+acl+selinux+ftype
                LSPP = FIPSR+sha512
                DATAONLY =  p+n+u+g+s+acl+selinux+xattrs+sha256+rmd160+tiger
                
                # System binaries
                /bin NORMAL
                /sbin NORMAL
                /usr/bin NORMAL
                /usr/sbin NORMAL
                /usr/local/bin NORMAL
                /usr/local/sbin NORMAL
                
                # System libraries
                /lib NORMAL
                /lib64 NORMAL
                /usr/lib NORMAL
                /usr/lib64 NORMAL
                /usr/local/lib NORMAL
                
                # Configuration files
                /etc PERMS
                !/etc/mtab
                !/etc/.*~
                !/etc/exports
                !/etc/fstab
                !/etc/passwd.lock
                !/etc/shadow.lock
                !/etc/mail/statistics
                !/etc/random-seed
                !/etc/adjtime
                !/etc/lvm/cache
                !/etc/lvm/backup
                !/etc/lvm/archive
                
                # Boot files
                /boot NORMAL
                
                # Root directory
                /root PERMS
                !/root/\..*
                
                # Logs (minimal monitoring)
                /var/log LOG
                !/var/log/aide
                !/var/log/lastlog
                !/var/log/faillog
                !/var/log/tallylog
                
                # Exclude temporary and variable files
                !/var/tmp
                !/tmp
                !/dev
                !/proc
                !/sys
                !/run
                !/var/run
                !/var/lock
                !/var/lib/aide
                !/var/cache
                !/var/spool
                !/home
                !/root/\.bash_history
                !/root/\.viminfo
              '';
            };
          })
          (lib.optionalAttrs isDarwin {
            "newsyslog.d/security-audit.conf" = {
              text = ''
                # logfilename                      [owner:group]    mode count size when  flags [/pid_file] [sig_num]
                /var/log/security-audit.log                         640  30    *    @T00  J
                /var/log/audit.log                                  640  30    *    @T00  J
                /var/log/audit-error.log                            640  30    *    @T00  J
              '';
            };
          })
        ];
    }
    systemdConfig
    launchdConfig
  ]);
}      

