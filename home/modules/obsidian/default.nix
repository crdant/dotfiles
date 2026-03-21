{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = lib.optionals isLinux [
    pkgs.unstable.obsidian
  ];

  homebrew = lib.mkIf isDarwin {
    casks = [
      "obsidian"
    ];
    masApps = {
      "Obsidian Web Clipper" = 6720708363;
    };
  };
}
