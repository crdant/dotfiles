{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  cfg = config.programs.opencode;

  toEnvVarName = path:
    let
      upper = lib.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      upperWithUnderscore = map (c: "_${c}") upper;
      withUnderscores = builtins.replaceStrings upper upperWithUnderscore path;
    in
      lib.toUpper (builtins.replaceStrings ["/"] ["_"] (lib.removePrefix "_" withUnderscores));

  mcpServersFromShared = import ../ai/config/mcp.nix {
    inherit config pkgs;
    secretRenderer = path: "{env:${toEnvVarName path}}";
  };
in {
  options.programs.opencode = {
    mcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = mcpServersFromShared;
      description = "OpenCode MCP server configurations";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "OpenCode plugins to install";
    };

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "OpenCode agent definitions";
    };
  };

  config = {
    home.packages = with pkgs; [
      unstable.opencode
    ];

    xdg.configFile = {
      "opencode/opencode.json".text = builtins.toJSON {
        mcp = cfg.mcpServers;
        instructions = [ "AGENTS.md" ];
      };

      # Install agents file-by-file to avoid clobbering user-created agents
      "opencode/agents/codebase-analyzer.md".source = ./config/agents/codebase-analyzer.md;
      "opencode/agents/codebase-locator.md".source = ./config/agents/codebase-locator.md;
      "opencode/agents/codebase-pattern-finder.md".source = ./config/agents/codebase-pattern-finder.md;
      "opencode/agents/docs-analyzer.md".source = ./config/agents/docs-analyzer.md;
      "opencode/agents/docs-locator.md".source = ./config/agents/docs-locator.md;
      "opencode/agents/git-commiter.md".source = ./config/agents/git-commiter.md;
      "opencode/agents/pull-request-author.md".source = ./config/agents/pull-request-author.md;
      "opencode/agents/web-search-researcher.md".source = ./config/agents/web-search-researcher.md;

      "opencode/AGENTS.md".source = ./config/AGENTS.md;
    };

    home.activation = {
      # Install Compound Engineering plugin for OpenCode
      opencodePlugins = let
        bunx = "${pkgs.bun}/bin/bunx";
      in lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
        $DRY_RUN_CMD ${bunx} @every-env/compound-plugin install compound-engineering --to opencode
      '';
    };

    programs.zsh.envExtra = ''
      # OpenCode MCP server secrets
      export FIRECRAWL_API_KEY="$(cat ${config.sops.secrets."firecrawl/api_key".path})"
      export SHORTCUT_API_TOKEN="$(cat ${config.sops.secrets."shortcut/api_token".path})"
      export OMNI_API_TOKEN="$(cat ${config.sops.secrets."omni/api_token".path})"
      export MCP_API_KEY="$OMNI_API_TOKEN"
      export GITHUB_TOKEN="$(cat ${config.sops.secrets."github/token".path})"
      export MBTA_API_KEY="$(cat ${config.sops.secrets."mbta/apiKey".path})"
      export GOOGLE_MAPS_API_KEY="$(cat ${config.sops.secrets."google/maps/apiKey".path})"
    '';
  };
}
