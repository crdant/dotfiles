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
      goose-cli
      unstable.github-mcp-server
      mbta-mcp-server
      llm
      mods
    ];
  
 
    # HACK because Claude code won't follow symlinks, replace with commented out file
    # stuff below as soon as possible
    activation = {
      claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.claude/commands
        $DRY_RUN_CMD cp -f ${../config/claude/commands}/* $HOME/.claude/commands/
      '';
    };

    file = {
      # ".claude" = {
      #   source = ./config/claude;
      #   recursive = true;
      # };
    } // lib.optionalAttrs isDarwin {
      "Library/Application Support/io.datasette.llm/templates" = {
        source = ../config/llm/templates;
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
                # ... your extensions config
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
                # ... rest of extensions
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
                mcpServers = import ../config/mcp.nix { inherit config pkgs; };
              };
        };
      };
  };
  
  # AI-specific Neovim plugins
  programs = {
    neovim = {
      plugins = with pkgs.vimPlugins; [
        # nvim-aider
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
        source = ../config/llm/templates;
        recursive = true;
      };
    };
  };

}
