{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Data analysis and database tools
  home.packages = with pkgs; [
    python313Packages.jupytext
  ] ++ lib.optionals isLinux [
    snowsql
  ];

  home.file = {
    ".snowsql" = {
      source = ./config/snowsql;
      recursive = true;
    };
  };
  
  programs = {
    zsh = {
      shellAliases = lib.mkIf isDarwin {
        snowsql = "/Applications/SnowSQL.app/Contents/MacOS/snowsql";
      };
    };
  };
}