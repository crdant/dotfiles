{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # CI/CD and pipeline tools
  home.packages = with pkgs; [
    argocd
    fluxcd
    goreleaser
    tektoncd-cli
  ] ++ lib.optionals isLinux [
    gist
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
    };
  };
}
