{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Container tools and OCI utilities
  home.packages = with pkgs; [
    apko
    crane
    imgpkg
    unstable.ko
    melange
    oras
    skopeo
    trivy
  ] ++ lib.optionals isLinux [
    nerdctl
  ];

  programs = {
    zsh = {
      oh-my-zsh = {
        plugins = [
        ];
      };
    };
  };
}