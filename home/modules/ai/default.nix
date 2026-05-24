{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  config = {
    # AI and coding assistant tools (non-agentic, shared across agents)
    home = {
      packages = with pkgs; [
        unstable.ollama
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
        hermes-agent
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
