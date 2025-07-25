{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # AI and coding assistant tools
  home = { 
    packages = with pkgs; [
      aider-chat-full
      unstable.claude-code
      unstable.fabric-ai
      gemini-cli
      goose-cli
      unstable.github-mcp-server
      llm
      mbta-mcp-server
      mods
      repomix
    ];
  
 
    # HACK because Claude code won't follow symlinks, replace with commented out file
    # stuff below as soon as possible
    activation = {
      claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.claude/commands
        $DRY_RUN_CMD cp -f ${./config/claude/commands}/* $HOME/.claude/commands/
      '';
    };

    file = {
      # ".claude" = {
      #   source = ./config/claude;
      #   recursive = true;
      # };
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
      
      "goose/config.yaml" = {
        path = "${config.home.homeDirectory}/.config/goose/config.yaml";
        mode = "0600";
        content = 
          let 
            # Same pattern for goose config
            gooseConfig = {
              GOOSE_PROVIDER = "anthropic";
              GOOSE_MODEL = "claude-3-7-sonnet-latest";
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
                git = {
                  cmd = "${pkgs.uv}/bin/uvx";
                  args = [ "mcp-server-git" ];
                  description = "A Model Context Protocol server for Git repository interaction and automation.";
                  envs = {};
                  name = "git";
                  enabled = true;
                  timeout = 300;
                  type = "stdio";
                };
                mbta = {
                  args = [ ];
                  cmd = "${pkgs.mbta-mcp-server}/bin/mbta-mcp-server";
                  description = "My unofficial MBTA MCP Server";
                  enabled = true;
                  envs = {
                    MBTA_API_KEY = config.sops.placeholder."mbta/apiKey";
                  };
                  name = "mbta";
                  timeout = 300;
                  type = "stdio";
                };
                github = {
                  args = [ "stdio" ];
                  cmd = "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server";
                  description = "GitHub's official MCP Server";
                  enabled = true;
                  envs = {
                    GITHUB_PERSONAL_ACCESS_TOKEN = config.sops.placeholder."github/token";
                  };
                  name = "github";
                  timeout = 300;
                  type = "stdio";
                };
                google-maps = {
                  cmd = "${pkgs.nodejs_22}/bin/npx";
                  args = [ "-y" "@modelcontextprotocol/server-google-maps" ];
                  description = "MCP Server for the Google Maps API.";
                  envs = {
                    GOOGLE_MAPS_API_KEY = "${config.sops.placeholder."google/maps/apiKey"}";
                  };
                  name = "google-maps";
                  enabled = true;
                  timeout = 300;
                  type = "stdio";
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
        neo-tree-nvim
        nvim-aider
        snacks-nvim
      ];
  
      extraLuaConfig = lib.mkAfter ''
        -- Aider integration
        -- require('nvim_aider').setup({})
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
