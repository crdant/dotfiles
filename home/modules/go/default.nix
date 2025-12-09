{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Go development tools
  home.packages = with pkgs; [
    gopls
    golangci-lint
  ];

  programs = {
    go = {
      enable = true;
      env = {
        GOPATH = [ "${config.home.homeDirectory}/workspace/go}" ];
      };
      package = pkgs.go;
    };
    
    # Go-specific Neovim configuration
    neovim = {
      extraLuaConfig = lib.mkAfter ''
        -- Go language server
        require('gopls')
        
        -- Set larger indents for Go files
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "go",
          callback = function()
            vim.opt_local.shiftwidth = 8
            vim.opt_local.tabstop = 8
          end
        })
        
        -- Auto format Go files on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            vim.cmd('silent! !go fmt %')
          end
        })
      '';
    };
  };
  
  xdg = {
    configFile = {
      "nvim/lua/gopls.lua" = {
        source = ./config/nvim/lua/gopls.lua;
      };
    };
  };
}
