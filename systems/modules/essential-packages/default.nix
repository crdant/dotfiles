{ pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
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
      darwin.trash
    ];
  };
}