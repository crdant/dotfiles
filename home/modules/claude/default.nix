{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
  cfg = config.programs.claude;

  # Seconds to wait for sops-nix to render mcp-servers.json before giving up
  mcpTemplateTimeout = 30;

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
    home = {
      packages = with pkgs; [
        claude-code-transcripts
        unstable.claude-code
      ];

      # HACK because Claude code won't follow symlinks, replace with commented out file
      # stuff below as soon as possible
      activation = {
        # Copy agents and commands to Claude config directories
        claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for CLAUDE_CONFIG_DIR in ${config.xdg.configHome}/claude/replicated ${config.xdg.configHome}/claude/personal ; do
            echo "Copying agents and commands to $CLAUDE_CONFIG_DIR..."
            $DRY_RUN_CMD mkdir -p $CLAUDE_CONFIG_DIR/commands $CLAUDE_CONFIG_DIR/agents
            $DRY_RUN_CMD cp -f ${./config/commands}/* $CLAUDE_CONFIG_DIR/commands
            $DRY_RUN_CMD cp -f ${./config/agents}/* $CLAUDE_CONFIG_DIR/agents
          done

        '';

        # Update mcpServers in Claude config files.
        #
        # On darwin the sops-nix activation entry only bootstraps a launchd agent and
        # returns, so entryAfter orders us against that call rather than against the
        # template existing. Poll for it, and skip rather than abort if it never lands —
        # a secret we cannot read should leave the old mcpServers in place, not fail
        # the whole switch.
        claudeMcpServers = lib.hm.dag.entryAfter [ "sops-nix" ] (''
          MCP_TEMPLATE="${config.sops.templates."mcp-servers.json".path}"

          WAITED=0
          while [ ! -s "$MCP_TEMPLATE" ] && [ "$WAITED" -lt ${toString mcpTemplateTimeout} ]; do
            sleep 1
            WAITED=$((WAITED + 1))
          done

          if [ ! -s "$MCP_TEMPLATE" ]; then
            warnEcho "claude: $MCP_TEMPLATE not rendered after ${toString mcpTemplateTimeout}s; leaving mcpServers unchanged."
            warnEcho "claude: check 'launchctl print gui/\$(id -u)/org.nix-community.home.sops-nix' and ~/Library/Logs/SopsNix/stderr."
          else
            MCP_SERVERS="$(cat "$MCP_TEMPLATE")"

            for CONFIG_DIR in ${config.xdg.configHome}/claude/replicated ${config.xdg.configHome}/claude/personal ; do
              CONFIG="$CONFIG_DIR/.claude.json"

              # $DRY_RUN_CMD cannot guard this: the shell performs the redirection
              # below before the command it prefixes ever runs.
              if [[ -v DRY_RUN ]]; then
                echo "Would set mcpServers in $CONFIG from $MCP_TEMPLATE"
                continue
              fi

              [ -f "$CONFIG" ] || echo '{}' > "$CONFIG"
              ${pkgs.jq}/bin/jq --argjson servers "$MCP_SERVERS" '.mcpServers = $servers' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
            done
          fi
        '' );

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

      fish = {
        shellInit = ''
          # set default for Claude config based on hostname
          if test "$(whoami)" = "chuck"
            set -gx CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude/replicated"
          else
            set -gx CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude/personal"
          end

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
