{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # CI/CD and pipeline tools
  home.packages = with pkgs; [
    argocd
    fluxcd
    gh
    goreleaser
    tektoncd-cli
  ] ++ lib.optionals isLinux [
    gist
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        gh
      ];
    };
    
    gh = {
      enable = true;
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git_protocol = "ssh";
      };
    };
    
    zsh = {
      oh-my-zsh = {
        plugins = [
          "gh"
        ];
      };
    };
  };
}