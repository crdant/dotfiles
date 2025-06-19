{ pkgs, lib, options,... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  supportsOpenSshSettings = builtins.hasAttr "settings" options.services.openssh;
  openSshSettings = lib.optionalAttrs supportsOpenSshSettings {
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  supportsOpenSshExtraConfig = builtins.hasAttr "extraConfig" options.services.openssh;
  openSshExtraConfig = lib.optionalAttrs supportsOpenSshExtraConfig {
    extraConfig = ''
      StreamLocalBindUnlink yes 
    ''; 
  };
in lib.mkMerge [
  # System services configuration
  { 
    services = {
      openssh = lib.mkMerge [
        {
          enable = true;
        }
        openSshSettings
        openSshExtraConfig
      ];
    };

  }
]
