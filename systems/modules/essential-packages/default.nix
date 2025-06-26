{ pkgs, lib, options,... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    homebrew = {
      enable = true;
      brews = [
        "watch"
      ];
    };
  };
in (lib.mkMerge [
  {
    # Essential packages for system administration and daily use
    environment = {
      systemPackages = with pkgs; [
        coreutils
        glow
        gnumake
        gnupg
        home-manager
        jq
        neovim
        nh
        openssh
        ripgrep
        tailscale
        tmux
        tree
        wget
        yq-go
        yubico-pam
      ] ++ lib.optionals isDarwin [
        mas
        m-cli
        darwin.trash
      ] ++ lib.optionals isLinux [
        unixtools.watch
      ];
    };
  }
  homebrewConfig
])
