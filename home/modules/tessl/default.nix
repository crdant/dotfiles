{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home = {
    # Tessl brand typography and the macOS apps used at work
    packages = with pkgs; [
      fira-code
      inter
    ] ++ lib.optionals isDarwin [
      linear
      notion-app
    ] ;
    file = lib.optionalAttrs isDarwin {
      "Library/Colors/Tessl.clr" = {
        source = ./config/palettes/Tessl.clr;
        recursive = true;
      };
    };
  };
}

