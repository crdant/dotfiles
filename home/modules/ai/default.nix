{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # AI and coding assistant tools
  home = { 
    packages = with pkgs; [
      aider-chat
      amp-cli
      nur.repos.charmbracelet.crush
      unstable.claude-code
      unstable.fabric-ai
      gemini-cli
      goose-cli
      unstable.github-mcp-server
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
        llm-tools-quickjs = true;
        llm-tools-simpleeval = true;
        llm-tools-sqlite = true;
        llm-venice = true;
      })
      mbta-mcp-server
      mods
      repomix
    ];
  
 
    # HACK because Claude code won't follow symlinks, replace with commented out file
    # stuff below as soon as possible
    activation = {
      claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        for CLAUDE_CONFIG_DIR in  ${config.xdg.configHome}/claude/replicated ${config.xdg.configHome}/claude/personal ; do
          echo "Copying agents and commands to $CLAUDE_CONFIG_DIR..."
          $DRY_RUN_CMD mkdir -p $CLAUDE_CONFIG_DIR/commands $CLAUDE_CONFIG_DIR/agents
          $DRY_RUN_CMD cp -f ${./config/claude/commands}/* $CLAUDE_CONFIG_DIR/commands
          $DRY_RUN_CMD cp -f ${./config/claude/agents}/* $CLAUDE_CONFIG_DIR/agents
        done

        # Only on sochu: copy Replicated's auto-installed managed agents/commands
        if [ "$(hostname -s)" = "sochu" ]; then
          if [ -d ~/.claude/agents ]; then
            echo "Copying Replicated managed agents to the Replicated Claude config directory..."
            $DRY_RUN_CMD cp -r ~/.claude/agents/* ${config.xdg.configHome}/claude/replicated/agents/
          fi

          if [ -d ~/.claude/commands ]; then
            echo "Copying Replicated managed commands to the Replicated Claude config directory..."
            $DRY_RUN_CMD cp -r ~/.claude/commands/* ${config.xdg.configHome}/claude/replicated/commands/
          fi
        fi
      '';
    };

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

  programs = {
    zsh = {
      envExtra = ''
        # set default for Claude config based on hostname
        if [[ "$(whoami)" == "chuck" ]] ; then
          export CLAUDE_CONFIG_DIR="${config.xdg.configHome}/claude/replicated"
        else
          export CLAUDE_CONFIG_DIR="${config.xdg.configHome}/claude/personal"
        fi
      '';
    };

  };

  # uncomment when Claude code can handle symlinks
  # xdg = {
  #   enable = true;
  #   configFile = {
  #     "claude/personal" = {
  #       source = ./config/claude;
  #       recursive = true;
  #     };
  #     "claude/replicated" = {
  #       source = ./config/claude;
  #       recursive = true;
  #     };
  #   };
  # };

  # AI-specific secrets
  sops = {
    secrets = {
      "anthropic/apiKeys/chuck@replicated.com" = {};
      "anthropic/apiKeys/chuck@crdant.io" = {};
      "github/token" = {};
      "google/maps/apiKey" = {};
      "mbta/apiKey" = {};
    };
    templates = {
      ".aider.conf.yml" = {
        path = "${config.home.homeDirectory}/.aider.conf.yml";
        mode = "0600";
        content = 
          let 
            # Create the configuration data structure first
            aiderConfig = {
              model = "sonnet";
              # Use the placeholder directly - this is safe because sops handles the substitution
              anthropic-api-key = config.sops.placeholder."anthropic/apiKeys/${gitEmail}";
              cache-prompts = true;
              architect = true;
              auto-accept-architect = false;
              multiline = true;
              vim = true;
              watch-files = true;
              notifications = true;
            };
            # Generate the YAML from the data structure
            yamlContent = (pkgs.formats.yaml { }).generate "aider-config" aiderConfig;
          in builtins.readFile yamlContent;
      };
      
      "crush/crush.json" = {
        path = "${config.home.homeDirectory}/.local/share/crush/crush.json";
        mode = "0600";
        content = builtins.toJSON {
          "$schema" = "https://charm.land/crush.json";
          providers = {
            anthropic = {
              api_key = config.sops.placeholder."anthropic/apiKeys/${gitEmail}";
            };
          };
          models = {
            large = {
              model = "claude-opus-4-20250514";
              provider = "anthropic";
              max_tokens = 32000;
            };
            small = {
              model = "claude-3-5-haiku-20241022";
              provider = "anthropic";
              max_tokens = 5000;
            };
          };
          lsp = {
            servers = {
              "Go" = {
                command = "${pkgs.gopls}/bin/gopls";
              };
              "Swift" = {
                command = "${pkgs.sourcekit-lsp}/bin/sourcekit-lsp";
              };
              "Rust" = {
                command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
              };
              "Python" = {
                command = "${pkgs.pyright}/bin/pyright-langserver";
              };
              "JavaScript" = {
                command = "${pkgs.typescript-language-server}/bin/typescript-language-server --stdio";
              };
              "TypeScript" = {
                command = "${pkgs.typescript-language-server}/bin/typescript-language-server --stdio";
              };
              "Markdown" = {
                command = "${pkgs.markdown-oxide}/bin/markdown-oxide";
              };
              "Nix" = {
                command = "${pkgs.nil}/bin/nil";
              };
            };
          };
          mcp = {
            servers = import ./config/mcp.nix { inherit config pkgs; };
          };
        };
      };

      "goose/config.yaml" = {
        path = "${config.home.homeDirectory}/.config/goose/config.yaml";
        mode = "0600";
        content = 
          let 
            # Same pattern for goose config
            gooseConfig = {
              GOOSE_PROVIDER = "claude-code";
              GOOSE_MODE = "smart_approve";
              extensions = {
                computercontroller = {
                  display_name = "Computer Controller";
                  enabled = true;
                  name = "computercontroller";
                  timeout = 300;
                  type = "builtin";
                };
                developer = {
                  display_name = "Developer Tools";
                  enabled = true;
                  name = "developer";
                  timeout = 300;
                  type = "builtin";
                };
                memory = {
                  display_name = "Memory";
                  enabled = true;
                  name = "memory";
                  timeout = 300;
                  type = "builtin";
                };
                repomix = {
                  display_name = "Repomix";
                  description = "Pack your codebase into AI-friendly formats";
                  cmd = "${pkgs.nodejs_22}/bin/npx";
                  args = [ "-y" "repomix" "--mcp" ];
                  enabled = true;
                  name = "repomix";
                  timeout = 300;
                  type = "stdio";
                };
              };
            };
            yamlContent = (pkgs.formats.yaml { }).generate "goose-config" gooseConfig;
          in builtins.readFile yamlContent;
      };
    } // lib.optionalAttrs isDarwin {
          "claude_desktop_config.json" = {
            path = "${config.home.homeDirectory}/Library/Application Support/Claude/claude_desktop_config.json";
            mode = "0600";
            content = builtins.toJSON {
                globalShortcut = "Cmd+Space";
                mcpServers = import ./config/mcp.nix { inherit config pkgs; };
              };
        };
      };
  };
  
  # AI-specific Neovim plugins
  programs = {
    neovim = {
      plugins = with pkgs.vimPlugins; [
        claude-code-nvim
        neo-tree-nvim
        nvim-aider
        plenary-nvim
        snacks-nvim
      ];
  
      extraLuaConfig = lib.mkAfter ''
        -- Aider integration
        require('nvim_aider').setup({})
        -- Claude code integration
        require('claude-code').setup({})
      '';
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

}
