{ config, pkgs, lib, options,... }:

let 
  cfg = config.systems.hardening;
  isLinux = pkgs.stdenv.isLinux;
  hasSudoRs = builtins.hasAttr "security.sudo-rs" options ;
  useSudoRsIfAvailable = lib.optionalAttrs hasSudoRs {
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
    };
  };
in {
  imports = [
    ./ssh.nix
    ./firewall.nix
    ./kernel.nix
    # ./users.nix
    # ./audit.nix
  ];

  options.systems.hardening = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable comprehensive system hardening";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    useSudoRsIfAvailable
    {
      environment.systemPackages = with pkgs; [
        fail2ban
        lynis
      ] ++ lib.optionals isLinux [
        aide
        chkrootkit
        unhide
      ];
    }
  ]);
}
