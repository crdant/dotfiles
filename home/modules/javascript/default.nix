{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # JavaScript/TypeScript development tools
  home.packages = with pkgs; [
    nodejs_22
    typescript-language-server
  ];

  programs = {
    # JavaScript/TypeScript-specific Neovim configuration
    neovim = {
      extraLuaConfig = lib.mkAfter ''
        -- TypeScript language server
        require('ts_ls')
      '';
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/ts_ls.lua" = {
        source = ./config/nvim/lua/ts_ls.lua;
      };
    };
  };
}