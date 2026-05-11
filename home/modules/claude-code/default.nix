{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let
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
  # This is defined in this repo's claude-code module, not by upstream home-manager.
  # Any module that sets programs.claude.plugins must be imported alongside
  # this module (today all profiles that include language modules also include claude-code).
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

        extraLuaConfig = lib.mkAfter ''
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
