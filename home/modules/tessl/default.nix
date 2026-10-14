{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home = {
    # Tessl typography: Fira Code and Inter for the brand, Atkinson
    # Hyperlegible (Next and Mono) for the design system, plus the
    # macOS apps used at work
    packages = with pkgs; [
      fira-code
      inter
      atkinson-hyperlegible
      atkinson-hyperlegible-next
      atkinson-hyperlegible-mono

      # Work tooling
      asciinema
      asciinema-agg
      postgresql
      temporal-cli
      tilt
    ] ++ lib.optionals isDarwin [
      linear
      notion-app
    ] ;
    file = lib.optionalAttrs isDarwin {
      "Library/Colors/Tessl Brand.clr" = {
        source = ./config/palettes + "/Tessl Brand.clr";
      };
      "Library/Colors/Tessl Design System.clr" = {
        source = ./config/palettes + "/Tessl Design System.clr";
      };
    };
  };
}

