{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home = {
    # Shortrib Labs brand typography: Space Grotesk for headings,
    # Source Serif 4 for body text, Source Code Pro for code
    packages = with pkgs; [
      space-grotesk
      source-serif
      source-code-pro
    ];
    file = lib.optionalAttrs isDarwin {
      "Library/Colors/Shortrib Labs Deep Simmer.clr" = {
        source = ./config/palettes/DeepSimmer.clr;
        recursive = true;
      };
    };
  };
}
