{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Data analysis and database tools
  home.packages = with pkgs; [
    python313Packages.jupytext
  ] ++ lib.optionals isLinux [
  ];
 
  programs = {
    neovim = {
      plugins = with pkgs.vimPlugins; [
        jupytext-nvim
        nvim-lspconfig
      ];
    };

  };
}
