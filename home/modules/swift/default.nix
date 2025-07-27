{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Swift and iOS development tools
  home.packages = with pkgs; [
  ] ++ lib.optionals isDarwin [
    jetbrains-toolbox
    sourcekit-lsp
    swiftlint
    terminal-notifier
    xcbeautify
    # avoid rabbit hole with swift versions
    # xcodegen
  ];

  programs = {
    # Swift-specific Neovim configuration
    neovim = {
      plugins = with pkgs.vimPlugins; [
      ] ++ lib.optionals isDarwin [
        # xcodebuild-nvim 
      ];

      extraLuaConfig = lib.mkAfter ''
        -- Swift language server
        require('sourcekit')
      '';
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/sourcekit.lua" = {
        source = ./config/nvim/lua/sourcekit.lua;
      };
    };
  };
}
