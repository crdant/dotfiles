{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  config = {
    # AI and coding assistant tools (non-agentic, shared across agents)
    home = {
      packages = with pkgs; [
        ollama
        (unstable.llm.withPlugins {
          llm-anthropic = true;
          llm-cmd = true;
          llm-echo = true;
          llm-fireworks = true;
          llm-gemini = true;
          llm-groq = true;
          llm-jq = true;
          llm-perplexity = true;
          llm-python = true;
          llm-templates-fabric = true;
          llm-tools-quickjs = false;
          llm-tools-simpleeval = true;
          llm-tools-sqlite = true;
          llm-venice = false;
        })
        mods
        repomix
        rodney
        showboat
        ttok
        unstable.fabric-ai
        unstable.github-mcp-server
        mbta-mcp-server
      ];

      file = {
      } // lib.optionalAttrs isDarwin {
        "Library/Application Support/io.datasette.llm/templates" = {
          source = ./config/llm/templates;
          recursive = true;
        };
      } // lib.optionalAttrs isLinux {
        "/home/crdant/.config/io.datasette.llm/templates" = {
          source = ./config/llm/templates;
          recursive = true;
        };
      };
    };

    # AI-specific secrets (shared across agents)
    sops = {
      secrets = {
        "anthropic/apiKeys/chuck@replicated.com" = {};
        "anthropic/apiKeys/chuck@crdant.io" = {};
        "github/token" = {};
        "google/maps/apiKey" = {};
        "mbta/apiKey" = {};
        "firecrawl/api_key" = {};
        "omni/api_token" = {};
        "shortcut/api_token" = {};
        "moonshot/apiKey" = {};
      };
    };

    xdg = {
      configFile = {
      } // lib.optionalAttrs isDarwin {
        "llm/templates" = {
          source = ./config/llm/templates;
          recursive = true;
        };
      };
    };

    programs = {
      # Avante.nvim — AI-powered editing assistant for Neovim
      neovim = {
        plugins = with pkgs.vimPlugins; [
          nui-nvim
          render-markdown-nvim
          avante-nvim
          img-clip-nvim
        ];

        extraLuaConfig = lib.mkAfter ''
          -- Avante.nvim configuration
          -- AI-powered code assistance within Neovim, complementing OpenCode
          require('avante').setup({
            provider = "moonshot",
            auto_suggestions_provider = "moonshot",
            providers = {
              moonshot = {
                endpoint = "https://api.moonshot.ai/v1",
                model = "kimi-k2-0711-preview",
                timeout = 30000,
                extra_request_body = {
                  temperature = 0.75,
                  max_tokens = 32768,
                },
              },
            },
            input = {
              provider = "snacks",
              provider_opts = {
                title = "Avante Input",
                icon = " ",
              },
            },
            selector = {
              provider = "fzf",
            },
            behaviour = {
              auto_suggestions = false,
              auto_set_keymaps = true,
              auto_apply_diff_after_generation = false,
              enable_token_counting = true,
              auto_add_current_file = true,
              auto_approve_tool_permissions = true,
              confirmation_ui_style = "inline_buttons",
            },
            windows = {
              position = "right",
              width = 30,
              input = {
                prefix = "> ",
                height = 8,
              },
            },
          })
        '';
      };

      zsh = {
        envExtra = ''
          # Avante.nvim Moonshot API key
          export AVANTE_MOONSHOT_API_KEY="$(cat ${config.sops.secrets."moonshot/apiKey".path})"
        '';
      };

      fish = {
        shellInit = ''
          # Avante.nvim Moonshot API key
          set -gx AVANTE_MOONSHOT_API_KEY (cat ${config.sops.secrets."moonshot/apiKey".path})
        '';
      };
    };
  };
}
