{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Python development tools
  home.packages = with pkgs; [
    pyright
    uv
    virtualenv
  ];

  programs = {
    # Python-specific Neovim configuration
    neovim = {
      extraLuaConfig = lib.mkAfter ''
        -- Python language server
        require('pyright')
      '';
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/pyright.lua" = {
        source = ./config/nvim/lua/pyright.lua;
      };
    };
  };
}