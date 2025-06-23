{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Infrastructure and cloud-agnostic tools
  home = {
    packages = with pkgs; [
      cloudflared
      leftovers
      packer
      terraform
      terraform-lsp
      vault
    ];
  };
  
  programs = {
    # Terraform-specific Neovim configuration
    neovim = {
      extraLuaConfig = lib.mkAfter ''
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

    
      envExtra = ''
        export REPL_USE_SUDO=y
        export GOVC_URL=https://vcenter.lab.shortrib.net
        export GOVC_USERNAME=administrator@shortrib.local
        # export GOVC_PASSWORD=$(security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w)
        export GOVC_INSECURE=true
      '';
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
