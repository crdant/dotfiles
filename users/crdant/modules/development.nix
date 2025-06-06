{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Development-related packages
  home.packages = with pkgs; [
    exercism
    gh
    git-lfs
    unstable.cue
    gopls
    unstable.ko
    nodejs_22
    nix-init
    nix-prefetch-git
    pyright
    llm
    rust-analyzer
    shellcheck
    typescript-language-server
    uv
    python313Packages.jupytext
  ] ++ lib.optionals isDarwin [
    jetbrains-toolbox
    sourcekit-lsp
    swiftlint
    terminal-notifier
    xcbeautify
    unstable.xcodegen
    vimr
    (callPackage ../vimr-wrapper.nix { inherit config; })
  ];

  programs = {
    git = {
      enable = true;
      
      userName = "Chuck D'Antonio";
      userEmail = "${gitEmail}";
      
      signing = {
        key = "0805EEDF0FEA6ACD";
        signByDefault = true;
      };
      
      aliases = { 
        ignore = "update-index --skip-worktree";
        unignore = "update-index --no-skip-worktree";
        ignored = "!git ls-files -v | grep \"^S\"";
        praise = "blame";
        unstash = "!f() { if [ $# -eq 0 ]; then echo \"Usage: git unstash <file1> [<file2> ...]\"; else for file in \"$@\"; do git checkout stash@{0} -- \"$file\"; done; fi }; f";
      };
      
      extraConfig = {
        core = {
          editor = "nvim";
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          
          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "${pkgs.openssh}/bin/ssh";
        };
        
        color = {
          ui = true;
          
          branch = { 
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };
          
          diff = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
            whitepace = "red reverse";
          };
          
          status = {
            added = "yellow";
            change = "green";
            untracked = "cyan";
          };
          
          merge = {
            conflictstyle = "zdiff3";
          };
          
          branch = {
            sort = "-commiterdate";
          };
        };
        
        init = {
          defaultBranch = "main";
        };
        
        diff = {
          plist = {
            textconv = "plutil -p";
          };
        };
        
        filter = {
          lfs = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
        };
      } // lib.optionalAttrs isDarwin {
        credential = {
          helper = "osxkeychain";
        };
      };
    };
    
    gh = {
      enable = true;
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git_protocol = "ssh";
      };
    };
    
    go = {
      enable = true;
      goPath = "workspace/go";
      package = pkgs.go;
    };
    
    # Development-specific Neovim configuration
    neovim.plugins = with pkgs.vimPlugins; [
      cmp-nvim-lsp
      conflict-marker-vim
      # copilot-vim
      {
        plugin = fzf-vim;
        config = ''
          " Initialize configuration dictionary
          let g:fzf_vim = {}
          let g:fzf_vim.preview_window = []
        ''; 
      }
      jupytext-nvim
      nvim-cmp
      nvim-lspconfig
      snacks-nvim
      supermaven-nvim
    ] ++ lib.optionals isDarwin [
      # xcodebuild-nvim 
    ];

    neovim.extraLuaConfig = lib.mkAfter ''
      -- Development-specific settings
      require('snacks').setup({})
      
      -- language servers
      require('gopls')
      require('pyright')
      require('rust_analyzer')
      require('sourcekit')
      require('terraform_lsp')
      require('ts_ls')
      
      -- other plugins
      require('jupytext').setup(
        {
          jupytext = '${pkgs.python313Packages.jupytext}/bin/jupytext',
          format = "markdown"
        }
      )
      
      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          
          -- Standard LSP keymaps
          local keymaps = {
            { "n", "gd", vim.lsp.buf.definition, "Go to definition" },
            { "n", "K", vim.lsp.buf.hover, "Show documentation" },
            { "n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol" },
            { "n", "<leader>ca", vim.lsp.buf.code_action, "Code actions" },
            { "n", "<leader>f", function() vim.lsp.buf.format { async = true } end, "Format buffer" },
          }
          
          -- Apply keybindings
          for _, keymap in ipairs(keymaps) do
            vim.keymap.set(keymap[1], keymap[2], keymap[3], { buffer = event.buf, desc = keymap[4] })
          end
        end
      })
      
      vim.api.nvim_set_keymap("n", "<C-P>", ":Files<CR>", { noremap = true })
      
      -- Supermaven setup
      require('supermaven-nvim').setup({})
      
      -- Challenge Edit functionality
      function ChallengeEdit(args)
        local dir = args.args
        
        -- open the assignment 
        vim.cmd('tabnew ' .. dir .. '/check-shell')
        
        -- create a vertical split with the check script, which
        -- will end up at the bottom
        vim.cmd('vnew ' .. dir .. '/assignment.md')
        
        -- Create two horizontal splits with the remaining files on
        -- right hand side
        
        vim.cmd('wincmd l')
        vim.cmd('new ' .. dir .. '/solve-shell')
        vim.cmd('new ' .. dir .. '/setup-shell')
      end
      
      local function challenge_completion(ArgLead, CmdLine, CursorPos)
        return vim.fn.getcompletion(ArgLead, 'dir')
      end
      
      vim.api.nvim_create_user_command('ChallengeEdit', ChallengeEdit, {
        nargs = 1,
        complete = challenge_completion
      })
      
      -- File-specific settings
      -- markdown should have spell check and word wrap
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.textwidth = 78
          vim.opt_local.spell = true
        end
      })
      
      -- Ensure Makefiles use tabs
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "make",
        callback = function()
          vim.opt_local.expandtab = false
        end
      })
      
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
  
  programs.zsh.oh-my-zsh.plugins = [
    "git"
    "gh"
  ];
  
  xdg.configFile = {
    "nvim" = {
      source = ../config/nvim;
      recursive = true;
    };
  };
}