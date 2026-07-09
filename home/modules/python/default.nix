{ inputs, outputs, options, config, pkgs, lib, ... }:

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
      initLua = lib.mkAfter ''
        -- Python language server
        require('pyright')
      '';
    };
  };

  # Claude Code plugin for Python language support
  programs.claude.plugins = [
    "pyright-lsp@claude-plugins-official"
  ];

  xdg = {
    configFile = {
      "nvim/lua/pyright.lua" = {
        source = ./config/nvim/lua/pyright.lua;
      };
    };
  };
}