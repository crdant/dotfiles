{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Rust development tools
  home.packages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
  ];

  programs = {
    # Rust-specific Neovim configuration
    neovim = {
      extraLuaConfig = lib.mkAfter ''
        -- Rust language server
        require('rust_analyzer')
      '';
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/rust_analyzer.lua" = {
        source = ./config/nvim/lua/rust_analyzer.lua;
      };
    };
  };
}