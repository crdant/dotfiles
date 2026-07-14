{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  cfg = config.programs.claude;

  # Seconds to wait for sops-nix to render mcp-servers.json before giving up
  mcpTemplateTimeout = 30;

  # Claude Code's own layout when CLAUDE_CONFIG_DIR is unset: the config file sits
  # next to the state directory, not inside it.
  claudeStateDir = "${config.home.homeDirectory}/.claude";
  claudeConfigFile = "${config.home.homeDirectory}/.claude.json";

  # Marketplace configuration — centralized here because attrsOf str
  # does not merge duplicate keys, even with identical values
  marketplaces = {
    "claude-plugins-official" = "anthropics/claude-plugins-official";
    "compound-engineering-plugin" = "EveryInc/compound-engineering-plugin";
    "compound-knowledge-marketplace" = "EveryInc/compound-knowledge-plugin";
    "last30days-skill" = "mvanhorn/last30days-skill";
    "replicatedhq" = "replicatedhq/replicated-claude-marketplace";
    "shortrib-labs" = "shortrib-labs/shortrib-claude-marketplace";
    "draft-review-kit-local" = "EveryInc/draft-review-kit";
  };
in {
  # Custom option for Claude Code plugin management.
  # This is defined in this repo's claude module, not by upstream home-manager.
  # Any module that sets programs.claude.plugins must be imported alongside
  # this module (today all profiles that include language modules also include claude).
  #
  # Each module contributes the plugins it owns; definitions concatenate. Keep the
  # default empty — a default is discarded as soon as any module defines the option,
  # so anything listed there would silently never install.
  options.programs.claude = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "pyright-lsp@claude-plugins-official" ];
      description = "Claude Code plugins to install (format: plugin-name@marketplace)";
    };
  };

  config = {
    home = {
      packages = with pkgs; [
        claude-code-transcripts
        unstable.claude-code
      ];

      # HACK because Claude code won't follow symlinks, replace with commented out file
      # stuff below as soon as possible
      activation = {
        # Copy agents and commands into the Claude state directory
        claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ -v DRY_RUN ]]; then
            echo "Would copy agents and commands to ${claudeStateDir}"
          else
            echo "Copying agents and commands to ${claudeStateDir}..."
            mkdir -p "${claudeStateDir}/commands" "${claudeStateDir}/agents"
            cp -f ${./config/commands}/* "${claudeStateDir}/commands"
            cp -f ${./config/agents}/* "${claudeStateDir}/agents"
          fi
        '';

        # Update mcpServers in the Claude config file. Note this sits beside the
        # state directory rather than inside it — that is Claude's own layout when
        # CLAUDE_CONFIG_DIR is unset.
        #
        # On darwin the sops-nix activation entry only bootstraps a launchd agent and
        # returns, so entryAfter orders us against that call rather than against the
        # template existing. Poll for it, and skip rather than abort if it never lands —
        # a secret we cannot read should leave the old mcpServers in place, not fail
        # the whole switch.
        claudeMcpServers = lib.hm.dag.entryAfter [ "sops-nix" ] (''
          MCP_TEMPLATE="${config.sops.templates."mcp-servers.json".path}"
          CONFIG="${claudeConfigFile}"

          WAITED=0
          while [ ! -s "$MCP_TEMPLATE" ] && [ "$WAITED" -lt ${toString mcpTemplateTimeout} ]; do
            sleep 1
            WAITED=$((WAITED + 1))
          done

          if [ ! -s "$MCP_TEMPLATE" ]; then
            warnEcho "claude: $MCP_TEMPLATE not rendered after ${toString mcpTemplateTimeout}s; leaving mcpServers unchanged."
            warnEcho "claude: check 'launchctl print gui/\$(id -u)/org.nix-community.home.sops-nix' and ~/Library/Logs/SopsNix/stderr."
          elif [[ -v DRY_RUN ]]; then
            echo "Would set mcpServers in $CONFIG from $MCP_TEMPLATE"
          else
            MCP_SERVERS="$(cat "$MCP_TEMPLATE")"

            [ -f "$CONFIG" ] || echo '{}' > "$CONFIG"
            ${pkgs.jq}/bin/jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
          fi
        '' );

        # Install Claude Code plugins declaratively
        # NOTE: additive only — plugins removed from config persist on disk until manually removed
        claudePlugins = let
          jq = "${pkgs.jq}/bin/jq";
          claude = "${pkgs.unstable.claude-code}/bin/claude";
        in lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "claude" ] ''
          export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

          # Target Claude's default location, not whatever the invoking shell exports.
          # A stale CLAUDE_CONFIG_DIR would otherwise send plugins somewhere else.
          unset CLAUDE_CONFIG_DIR

          if [[ -v DRY_RUN ]]; then
            echo "Would register ${toString (lib.length (lib.attrNames marketplaces))} marketplaces and install ${toString (lib.length cfg.plugins)} plugins in ${claudeStateDir}"
          else
            mkdir -p "${claudeStateDir}/plugins"

            KNOWN_MARKETPLACES="${claudeStateDir}/plugins/known_marketplaces.json"

            # Register marketplaces. Skip only when the entry is known *and* its
            # installLocation still exists — the manifest records absolute paths, so
            # a moved config directory leaves entries pointing at nothing. Treating
            # those as "known" makes the plugin installs below fail on a missing
            # source path.
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: source: ''
            MARKETPLACE_DIR=""
            if [ -f "$KNOWN_MARKETPLACES" ]; then
              MARKETPLACE_DIR="$(${jq} -r --arg name ${lib.escapeShellArg name} '.[$name].installLocation // empty' "$KNOWN_MARKETPLACES")"
            fi

            if [ -z "$MARKETPLACE_DIR" ] || [ ! -d "$MARKETPLACE_DIR" ]; then
              ${claude} plugin marketplace add ${lib.escapeShellArg source}
            fi
            '') marketplaces)}

            # Install plugins (install is idempotent — handles both new and existing plugins)
            ${lib.concatStringsSep "\n" (map (plugin: ''
            ${claude} plugin install ${lib.escapeShellArg plugin}
            '') cfg.plugins)}
          fi
        '';
      };
    };

    programs = {
      # Plugins that tune Claude Code itself rather than any language or workflow,
      # so they belong with the harness. Language and workflow plugins are defined
      # by the modules that own them.
      claude.plugins = [
        "claude-md-management@claude-plugins-official"
        "hookify@claude-plugins-official"
        "last30days@last30days-skill"
        "skill-creator@claude-plugins-official"
      ];

      zsh = {
        envExtra = ''
          # use MCP tool search in Claude Code
          export ENABLE_TOOL_SEARCH=true
        '';
      };

      fish = {
        shellInit = ''
          # use MCP tool search in Claude Code
          set -gx ENABLE_TOOL_SEARCH true
        '';
      };

      # Claude-specific Neovim plugins
      neovim = {
        plugins = with pkgs.vimPlugins; [
          claude-code-nvim
        ];

        initLua = lib.mkAfter ''
          -- Claude code integration
          require('claude-code').setup({})
        '';
      };
    };

    # Claude-specific sops template for MCP servers
    sops = {
      templates = {
        # MCP servers configuration for Claude
        "mcp-servers.json" = {
          path = "${config.xdg.dataHome}/claude/mcp-servers.json";
          mode = "0600";
          content = builtins.toJSON (import ../ai/config/mcp.nix { inherit config pkgs; });
        };
      };
    };
  };
}
