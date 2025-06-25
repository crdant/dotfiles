{ config, pkgs, lib, ... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = lib.mkIf isLinux {
      # Network hardening
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;
      
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      
      "net.ipv4.tcp_timestamps" = 0;
      
      # Prevent SYN flood attacks
      "net.ipv4.tcp_synack_retries" = 2;
      "net.ipv4.tcp_syn_retries" = 5;
      "net.ipv4.tcp_max_syn_backlog" = 4096;
      
      # IP forwarding
      "net.ipv4.ip_forward" = 0;
      "net.ipv6.conf.all.forwarding" = 0;
      
      # Kernel hardening
      "kernel.randomize_va_space" = 2;
      "kernel.kptr_restrict" = 2;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.core_uses_pid" = 1;
      
      "kernel.sysrq" = 0;
      "kernel.exec-shield" = 1;
      
      "kernel.dmesg_restrict" = 1;
      "kernel.kexec_load_disabled" = 1;
      
      "kernel.pid_max" = 65536;
      
      # File system hardening
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      
      # Restrict core dumps
      "fs.suid_dumpable" = 0;
      "kernel.core_pattern" = "|/bin/false";
      
      # Already defined above - removed duplicates
      
      # Restrict loading kernel modules
      "kernel.modules_disabled" = 0;
      
      # Increase inotify limits
      "fs.inotify.max_user_watches" = 524288;
      
      # IPv6 privacy extensions
      "net.ipv6.conf.all.use_tempaddr" = 2;
      "net.ipv6.conf.default.use_tempaddr" = 2;
      
      # Protect against time-wait assassination
      "net.ipv4.tcp_rfc1337" = 1;
      
      # Increase entropy
      "kernel.random.poolsize" = 4096;
      "kernel.random.min_urandom_seed" = 4096;
      
      # Already defined above - removed duplicates
      
      # Already defined above - removed duplicates
      
      # Already defined above - removed duplicates
      
      # Ignore ICMP ping requests
      "net.ipv4.icmp_echo_ignore_all" = 0;
      
      # Already defined above - removed duplicates
      
      # Already defined above - removed duplicates
    };
    
    boot.kernelParams = lib.mkIf isLinux [
      "security=apparmor"
      "apparmor=1"
      "page_poison=1"
      "slab_nomerge"
      "slub_debug=FZ"
      "init_on_alloc=1"
      "init_on_free=1"
      "pti=on"
      "vsyscall=none"
      "debugfs=off"
      "oops=panic"
      "quiet"
      "loglevel=3"
    ];
    
    boot.blacklistedKernelModules = lib.mkIf isLinux [
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "n-hdlc"
      "ax25"
      "netrom"
      "x25"
      "rose"
      "decnet"
      "econet"
      "af_802154"
      "ipx"
      "appletalk"
      "psnap"
      "p8023"
      "p8022"
      "can"
      "atm"
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "squashfs"
      "udf"
      "bluetooth"
      "btusb"
      "uvcvideo"
    ];
    
    system.activationScripts.kernel-hardening = lib.mkIf isDarwin {
      text = ''
        # macOS kernel hardening via sysctl
        
        # Network hardening
        sysctl -w net.inet.ip.forwarding=0 2>/dev/null || true
        sysctl -w net.inet.ip.redirect=0 2>/dev/null || true
        sysctl -w net.inet.ip.sourceroute=0 2>/dev/null || true
        sysctl -w net.inet.tcp.blackhole=2 2>/dev/null || true
        sysctl -w net.inet.udp.blackhole=1 2>/dev/null || true
        sysctl -w net.inet.icmp.icmplim=50 2>/dev/null || true
        
        # Kernel hardening
        sysctl -w kern.sysv.shmmax=1048576 2>/dev/null || true
        sysctl -w kern.sysv.shmmin=1 2>/dev/null || true
        sysctl -w kern.sysv.shmmni=32 2>/dev/null || true
        sysctl -w kern.sysv.shmseg=8 2>/dev/null || true
        sysctl -w kern.sysv.shmall=1024 2>/dev/null || true
        
        # Security
        sysctl -w security.mac.sandbox.sentinel=1 2>/dev/null || true
        sysctl -w security.mac.vnode.enforce=1 2>/dev/null || true
      '';
    };
    
    environment.etc = lib.mkIf isDarwin {
      "sysctl.conf" = {
        text = ''
          # macOS kernel security settings
          net.inet.ip.forwarding=0
          net.inet.ip.redirect=0
          net.inet.ip.sourceroute=0
          net.inet.tcp.blackhole=2
          net.inet.udp.blackhole=1
          net.inet.icmp.icmplim=50
          
          # Limit shared memory
          kern.sysv.shmmax=1048576
          kern.sysv.shmmin=1
          kern.sysv.shmmni=32
          kern.sysv.shmseg=8
          kern.sysv.shmall=1024
        '';
      };
    };
  };
}