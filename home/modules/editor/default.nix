{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Core editor configuration
  home.packages = with pkgs; [
    markdown-oxide
  ];

  programs = {
    # Core Neovim configuration
    neovim = {
      extraLuaPackages = ps: [ ps.magick ];
      extraPackages = [ pkgs.imagemagick ];

      plugins = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        conflict-marker-vim
        {
          plugin = fzf-vim;
          config = ''
            " Initialize configuration dictionary
            let g:fzf_vim = {}
            let g:fzf_vim.preview_window = []
          ''; 
        }
        image-nvim
        jupytext-nvim
        neo-tree-nvim
        nvim-web-devicons
        nvim-cmp
        nvim-lspconfig
        supermaven-nvim
        vim-surround
        vim-commentary
      ];

      extraLuaConfig = ''
        -- Core editor settings
        require('snacks').setup({})
        
        -- Core plugins setup
        require('jupytext').setup(
          {
            jupytext = '${pkgs.python313Packages.jupytext}/bin/jupytext',
            format = "markdown"
          }
        )

        if vim.fn.has('gui_running') ~= 1 then
          require('image').setup({})
        end
        
        -- Neotree setup
        require('neo-tree').setup({
          close_if_last_window = true,
          popup_border_style = "rounded",
          enable_git_status = true,
          filesystem = {
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
              hide_gitignored = true,
              hide_by_name = {
                ".git",
              },
            },
          },
        })

        -- Core LSP keybindings
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
        
        vim.api.nvim_create_autocmd("TabNewEntered", {
          callback = function()
            vim.cmd("Neotree show")
          end,
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
      '';
    };
  };
}
