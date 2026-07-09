{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # JavaScript/TypeScript development tools
  home.packages = with pkgs; [
    bun
    nodejs_22
    typescript-language-server
  ];

  programs = {
    # JavaScript/TypeScript-specific Neovim configuration
    neovim = {
      initLua = lib.mkAfter ''
        -- TypeScript language server
        require('ts_ls')
      '';
    };
  };

  # Claude Code plugin for TypeScript language support
  programs.claude.plugins = [
    "typescript-lsp@claude-plugins-official"
  ];

  xdg = {
    configFile = {
      "nvim/lua/ts_ls.lua" = {
        source = ./config/nvim/lua/ts_ls.lua;
      };
    };
  };
}