{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Infrastructure and cloud-agnostic tools
  home = {
    packages = with pkgs; [
      cloudflared
      doggo
      leftovers
      # unstable.packer
      restic
      talosctl
      terraform
      terraform-lsp
      vault
    ];
  };
  
  programs = {
    # Terraform-specific Neovim configuration
    neovim = {
      initLua = lib.mkAfter ''
        -- Terraform language server
        require('terraform_lsp')
      '';
    };
    
    zsh = {
      oh-my-zsh = {
        plugins = [
          "vault"
          "terraform"
        ];
      };
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/terraform_lsp.lua" = {
        source = ./config/nvim/lua/terraform_lsp.lua;
      };
    };
  };
}
