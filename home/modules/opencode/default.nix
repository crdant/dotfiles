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

  # Transform shared MCP config to OpenCode's expected format
  # OpenCode expects:
  # - type: "local" | "remote"
  # - command: array (command + args combined)
  # - environment: object (instead of env)
  # - enabled: boolean
  toOpenCodeMcp = servers: lib.mapAttrs (name: server:
    let
      isRemote = server.type or "" == "http";
      # Combine command and args into single array for local servers
      commandArray = if server ? command
        then [ server.command ] ++ (server.args or [])
        else (server.args or []);
    in
    if isRemote then {
      type = "remote";
      enabled = true;
      url = server.url;
      headers = server.headers or {};
    } else {
      type = "local";
      enabled = true;
      command = commandArray;
      environment = server.env or {};
    }
  ) servers;

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

    home.activation = {
      # Copy agent definitions to opencode config directory (avoids symlink warnings)
      opencodeAgents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        AGENTS_DIR="${config.xdg.configHome}/opencode/agents"
        $DRY_RUN_CMD mkdir -p "$AGENTS_DIR"
        $DRY_RUN_CMD cp -f ${./config/agents}/*.md "$AGENTS_DIR/"
        $DRY_RUN_CMD cp -f ${./config/AGENTS.md} "${config.xdg.configHome}/opencode/AGENTS.md"
      '';

      # Merge MCP servers into existing opencode.json (preserves user settings)
      opencodeMcpServers = lib.hm.dag.entryAfter [ "sops-nix" ] ''
        OPENCODE_CONFIG="${config.xdg.configHome}/opencode/opencode.json"

        # Ensure config file exists
        [ -f "$OPENCODE_CONFIG" ] || echo '{"$schema":"https://opencode.ai/config.json"}' > "$OPENCODE_CONFIG"

        # Generate our MCP config as JSON with OpenCode's expected format
        MCP_JSON='${builtins.toJSON { mcp = toOpenCodeMcp cfg.mcpServers; instructions = [ "AGENTS.md" ]; }}'

        # Merge into existing config using jq (preserves user settings)
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$OPENCODE_CONFIG" <(echo "$MCP_JSON") > "$OPENCODE_CONFIG.tmp" && mv "$OPENCODE_CONFIG.tmp" "$OPENCODE_CONFIG"
      '';

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

    programs.fish.shellInit = ''
      # OpenCode MCP server secrets
      set -gx FIRECRAWL_API_KEY (cat ${config.sops.secrets."firecrawl/api_key".path})
      set -gx SHORTCUT_API_TOKEN (cat ${config.sops.secrets."shortcut/api_token".path})
      set -gx OMNI_API_TOKEN (cat ${config.sops.secrets."omni/api_token".path})
      set -gx MCP_API_KEY $OMNI_API_TOKEN
      set -gx GITHUB_TOKEN (cat ${config.sops.secrets."github/token".path})
      set -gx MBTA_API_KEY (cat ${config.sops.secrets."mbta/apiKey".path})
      set -gx GOOGLE_MAPS_API_KEY (cat ${config.sops.secrets."google/maps/apiKey".path})
    '';
  };
}
