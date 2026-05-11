{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  cfg = config.programs.codex;

  # Shared MCP server definitions from the ai module
  sharedMcp = import ../ai/config/mcp.nix { inherit config pkgs; };

  # Detect sops placeholder strings so we can separate secrets from static values
  isSopsPlaceholder = val:
    lib.isString val && lib.hasPrefix "<SOPS:" val && lib.hasSuffix ":PLACEHOLDER>" val;

  # Map a shared MCP server definition into Codex's TOML schema
  mapServer = name: server:
    let
      # Base fields: drop the github command (it is an HTTP server)
      base = lib.optionalAttrs (server ? command && name != "github") { inherit (server) command; }
        // lib.optionalAttrs (server ? args) { inherit (server) args; }
        // lib.optionalAttrs (server ? type) { inherit (server) type; }
        // lib.optionalAttrs (server ? url) { inherit (server) url; };

      # Split env into static values (passed via [mcp_servers.<name>.env]) and
      # secret values (forwarded via env_vars from the shell environment)
      envVars = lib.optionalAttrs (server ? env) (
        let
          secretKeys = lib.filter (k: isSopsPlaceholder server.env.${k}) (lib.attrNames server.env);
          staticEnv = lib.filterAttrs (k: v: !isSopsPlaceholder v) server.env;
        in
        lib.optionalAttrs (secretKeys != []) { env_vars = secretKeys; }
        // lib.optionalAttrs (staticEnv != {}) { env = staticEnv; }
      );

      # GitHub HTTP server uses a bearer token env var instead of a composed header
      githubExtra = lib.optionalAttrs (name == "github") {
        bearer_token_env_var = "GITHUB_TOKEN";
      };
    in
    base // envVars // githubExtra;

  tomlFormat = pkgs.formats.toml { };

  codexToml = {
    mcp_servers = lib.mapAttrs mapServer cfg.mcpServers;
    approval_policy = "on-request";
    sandbox_mode = "read-only";
    model = "gpt-5.4";
    project_doc_fallback_filenames = [ "AGENTS.md" "CLAUDE.md" ];
  };
in
  {
  options.programs.codex = {
    mcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = sharedMcp;
      description = "MCP servers configuration for Codex";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Codex plugins to install";
    };

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Codex skills to enable";
    };
  };

  config = {
    home.packages = [ pkgs.unstable.codex ];

    # Render merged MCP servers and top-level settings into ~/.codex/config.toml
    home.file.".codex/config.toml".source = tomlFormat.generate "codex-config.toml" codexToml;

    # Custom instructions that Codex reads natively
    home.file.".codex/AGENTS.md".text = ''
      # Codex Custom Instructions

      ## Role
      You are a helpful coding assistant integrated into the terminal.

      ## Guidelines
      - Follow existing code style and conventions.
      - Write tests for new functionality.
      - Prefer simple, clear solutions.
      - Ask clarifying questions when requirements are ambiguous.
    '';

    # Export sops-backed secrets as environment variables so Codex can forward
    # them to MCP stdio servers via env_vars.
    programs.zsh.envExtra = ''
      # Codex MCP secrets
      export FIRECRAWL_API_KEY="$(cat ${config.sops.secrets."firecrawl/api_key".path})"
      export SHORTCUT_API_TOKEN="$(cat ${config.sops.secrets."shortcut/api_token".path})"
      export OMNI_API_TOKEN="$(cat ${config.sops.secrets."omni/api_token".path})"
      export MCP_API_KEY="$OMNI_API_TOKEN"
      export GITHUB_TOKEN="$(cat ${config.sops.secrets."github/token".path})"
      export MBTA_API_KEY="$(cat ${config.sops.secrets."mbta/apiKey".path})"
      export GOOGLE_MAPS_API_KEY="$(cat ${config.sops.secrets."google/maps/apiKey".path})"
    '';

    home.activation = {
      # Install Compound Engineering plugin for Codex
      # Steps:
      # 1. Register marketplace
      # 2. Install compound-engineering agents via bunx
      codexPlugins = let
        codex = "${pkgs.unstable.codex}/bin/codex";
        bunx = "${pkgs.bun}/bin/bunx";
      in lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
        # Register Compound Engineering marketplace if not already registered
        $DRY_RUN_CMD ${codex} plugin marketplace add EveryInc/compound-engineering-plugin || true

        # Install compound-engineering agents (idempotent)
        $DRY_RUN_CMD ${bunx} @every-env/compound-plugin install compound-engineering --to codex

        # Install plugins listed in config (idempotent through codex TUI)
        ${lib.concatStringsSep "\n" (map (plugin: ''
          $DRY_RUN_CMD ${codex} plugin install ${lib.escapeShellArg plugin}
        '') cfg.plugins)}
      '';
    };
  };
}
