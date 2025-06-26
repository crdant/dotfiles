{ config, pkgs, lib, options,... }:

let 
  cfg = config.systems.hardening;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    ./ssh.nix
    ./firewall.nix
    ./kernel.nix
    ./users.nix
    ./audit.nix
  ];

  options.systems.hardening = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable comprehensive system hardening";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fail2ban
      lynis
    ] ++ lib.optionals isLinux [
      aide
      chkrootkit
      unhide
    ];
  };
}
