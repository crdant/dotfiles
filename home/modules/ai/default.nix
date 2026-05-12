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
        "fireworks/apiKey/personal" = {};
        "fireworks/apiKey/replicated" = {};
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
          -- Uses Fireworks.ai (OpenAI-compatible API) for inference
          require('avante').setup({
            provider = "fireworks",
            auto_suggestions_provider = "fireworks",
            providers = {
              fireworks = {
                __inherited_from = "openai",
                endpoint = "https://api.fireworks.ai/inference/v1",
                api_key_name = "FIREWORKS_API_KEY",
                model = "accounts/fireworks/models/llama-v3p1-405b-instruct",
                timeout = 30000,
                extra_request_body = {
                  temperature = 0.75,
                  max_tokens = 4096,
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
          # Avante.nvim Fireworks API key
          # Switches between personal and replicated keys based on user
          if [[ "$(whoami)" == "chuck" ]] ; then
            export FIREWORKS_API_KEY="$(cat ${config.sops.secrets."fireworks/apiKey/replicated".path})"
          else
            export FIREWORKS_API_KEY="$(cat ${config.sops.secrets."fireworks/apiKey/personal".path})"
          fi
        '';
      };

      fish = {
        shellInit = ''
          # Avante.nvim Fireworks API key
          # Switches between personal and replicated keys based on user
          if test "$(whoami)" = "chuck"
            set -gx FIREWORKS_API_KEY (cat ${config.sops.secrets."fireworks/apiKey/replicated".path})
          else
            set -gx FIREWORKS_API_KEY (cat ${config.sops.secrets."fireworks/apiKey/personal".path})
          end
        '';
      };
    };
  };
}
