{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  cfg = config.programs.claude;

  # Marketplace configuration — centralized here because attrsOf str
  # does not merge duplicate keys, even with identical values
  marketplaces = {
    "claude-plugins-official" = "anthropics/claude-plugins-official";
    "compound-engineering-plugin" = "EveryInc/compound-engineering-plugin.git";
    "compound-knowledge-marketplace" = "EveryInc/compound-knowledge-plugin.git";
    "last30days-skill" = "mvanhorn/last30days-skill";
    "replicatedhq" = "replicatedhq/replicated-claude-marketplace";
    "shortrib-labs" = "shortrib-labs/shortrib-claude-marketplace";
  };
in {
  # Custom option for Claude Code plugin management.
  # This is defined in this repo's AI module, not by upstream home-manager.
  # Any module that sets programs.claude.plugins must be imported alongside
  # this module (today all profiles that include language modules also include AI).
  options.programs.claude = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Language LSP plugins — move to respective language modules as they adopt programs.claude.plugins
        "pyright-lsp@claude-plugins-official"
        "swift-lsp@claude-plugins-official"
        "typescript-lsp@claude-plugins-official"
        # Tool plugins
        "skill-creator@claude-plugins-official"
        "claude-md-management@claude-plugins-official"
        "compound-engineering@compound-engineering-plugin"
        "compound-knowledge@compound-knowledge-marketplace"
        "last30days@last30days-skill"
        "taste@shortrib-labs"
        "strategy@shortrib-labs"
        "writing@shortrib-labs"
        "hookify@claude-plugins-official"
      ];
      description = "Claude Code plugins to install (format: plugin-name@marketplace)";
    };
  };

  config = {
    # AI and coding assistant tools
    home = {
      packages = with pkgs; [
        aider-chat
        amp-cli
        ollama
        nur.repos.charmbracelet.crush
        claude-code-transcripts
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
          llm-tools-quickjs = false;
          llm-tools-simpleeval = true;
          llm-tools-sqlite = true;
          llm-venice = false;
        })
        mbta-mcp-server
        mods
        repomix
        rodney
        showboat
        ttok
      ];


      # HACK because Claude code won't follow symlinks, replace with commented out file
      # stuff below as soon as possible
      activation = {
        # Copy agents and commands to Claude config directories
        claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for CLAUDE_CONFIG_DIR in ${config.xdg.configHome}/claude/replicated ${config.xdg.configHome}/claude/personal ; do
            echo "Copying agents and commands to $CLAUDE_CONFIG_DIR..."
            $DRY_RUN_CMD mkdir -p $CLAUDE_CONFIG_DIR/commands $CLAUDE_CONFIG_DIR/agents
            $DRY_RUN_CMD cp -f ${./config/claude/commands}/* $CLAUDE_CONFIG_DIR/commands
            $DRY_RUN_CMD cp -f ${./config/claude/agents}/* $CLAUDE_CONFIG_DIR/agents
          done

          # Only on sochu: copy Replicated's auto-installed managed agents/commands
          if [ "$(/bin/hostname -s)" = "sochu" ]; then
            if [ -d ~/.claude/agents ] && [ -n "$(ls -A ~/.claude/agents 2>/dev/null)" ]; then
              echo "Copying Replicated managed agents to the Replicated Claude config directory..."
              $DRY_RUN_CMD cp -r ~/.claude/agents/* ${config.xdg.configHome}/claude/replicated/agents/
            fi

            if [ -d ~/.claude/commands ] && [ -n "$(ls -A ~/.claude/commands 2>/dev/null)" ]; then
              echo "Copying Replicated managed commands to the Replicated Claude config directory..."
              $DRY_RUN_CMD cp -r ~/.claude/commands/* ${config.xdg.configHome}/claude/replicated/commands/
            fi
          fi
        '';

        # Update mcpServers in Claude config files
        claudeMcpServers = lib.hm.dag.entryAfter [ "sops-nix" ] (''
          MCP_SERVERS="$(cat ${config.sops.templates."mcp-servers.json".path})"

          if [ -n "$MCP_SERVERS" ]; then
            for CONFIG_DIR in ${config.xdg.configHome}/claude/replicated ${config.xdg.configHome}/claude/personal ; do
              CONFIG="$CONFIG_DIR/.claude.json"
              [ -f "$CONFIG" ] || echo '{}' > "$CONFIG"
              ${pkgs.jq}/bin/jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
            done
          fi
        '' ); # ++ lib.optionalString isDarwin ''
          # if [ -n "$MCP_SERVERS" ]; then
          #   CONFIG="${config.home.homeDirectory}/Library/Application Support/Claude/claude_desktop_config.json"
          #   mkdir -p "$(dirname "$CONFIG")"
          #   [ -f "$CONFIG" ] || echo '{}' > "$CONFIG"
          #   ${pkgs.jq}/bin/jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
          # fi
        # '');

        # Install Claude Code plugins declaratively
        # NOTE: additive only — plugins removed from config persist on disk until manually removed
        claudePlugins = let
          jq = "${pkgs.jq}/bin/jq";
          claude = "${pkgs.unstable.claude-code}/bin/claude";
        in lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "claude" ] ''
          export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

          for CLAUDE_CONFIG_DIR in ${config.xdg.configHome}/claude/personal ${config.xdg.configHome}/claude/replicated ; do
            export CLAUDE_CONFIG_DIR
            $DRY_RUN_CMD mkdir -p "$CLAUDE_CONFIG_DIR/plugins"

            KNOWN_MARKETPLACES="$CLAUDE_CONFIG_DIR/plugins/known_marketplaces.json"

            # Register marketplaces (skip if already known)
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: source: ''
            if [ ! -f "$KNOWN_MARKETPLACES" ] || ! ${jq} --arg name ${lib.escapeShellArg name} -e '.[$name]' "$KNOWN_MARKETPLACES" > /dev/null 2>&1; then
              $DRY_RUN_CMD ${claude} plugin marketplace add ${lib.escapeShellArg source}
            fi
            '') marketplaces)}

            # Install plugins (install is idempotent — handles both new and existing plugins)
            ${lib.concatStringsSep "\n" (map (plugin: ''
            $DRY_RUN_CMD ${claude} plugin install ${lib.escapeShellArg plugin}
            '') cfg.plugins)}
          done
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

          # use MCP tool search in Claude Code
          ENABLE_TOOL_SEARCH=true
        '';
      };

      # AI-specific Neovim plugins
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
        "firecrawl/api_key" = {};
        "omni/api_token" = {};
        "shortcut/api_token" = {};
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

        # MCP servers configuration for Claude
        "mcp-servers.json" = {
          path = "${config.xdg.dataHome}/claude/mcp-servers.json";
          mode = "0600";
          content = builtins.toJSON (import ./config/mcp.nix { inherit config pkgs; });
        };
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
  };
}
