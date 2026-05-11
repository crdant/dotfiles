---
date: 2026-05-04
topic: agent-module-refactor
---

# Refactor AI Module into Per-Agent Modules

## Problem Frame

The `ai` module is a monolith that installs and configures six agentic coding tools (Claude Code, aider, amp, goose, gemini-cli, crush) alongside non-agentic AI utilities. Only three agents are actively wanted (Claude Code, opencode, codex), each needing distinct config at full depth. The current structure makes it hard to maintain per-agent config, and dead tool config accumulates.

---

## Requirements

**Shared AI module (`home/modules/ai/`)**
- R1. The `ai` module retains non-agentic AI packages: ollama, llm (with plugins), mods, fabric-ai, repomix, ttok, rodney, showboat, and llm templates.
- R2. The `ai` module retains the shared MCP server config (`config/mcp.nix`) and its sops secrets, available for agent modules to import.
- R3. The `ai` module retains shell environment setup (CLAUDE_CONFIG_DIR, ENABLE_TOOL_SEARCH) that applies across agents.

**Cross-module composition via Nix options**
- R4. Each agent module defines `lib.mkOption`-based options for its extensible config surfaces (e.g. `programs.claude.plugins`, `programs.opencode.mcpServers`, `programs.codex.mcpServers`). Other modules (language, development, etc.) set these options to contribute config, and Nix's `mkMerge` combines them — the same pattern `programs.claude.plugins` uses today.
- R5. Each agent module renders its merged option values into the tool's native config format (JSON for OpenCode, TOML for Codex, activation scripts for Claude Code).

**Claude Code module (`home/modules/claude-code/`)**
- R6. Claude Code gets its own sibling module at `home/modules/claude-code/` with the package (`unstable.claude-code`), `claude-code-transcripts`, and `claude-code-nvim` neovim plugin.
- R7. Claude Code module owns all Claude-specific activation scripts: agent/command copying, MCP server injection into `.claude.json`, and plugin installation.
- R8. Claude Code module owns the `programs.claude` option definition (plugins list) and the marketplace/plugin installation logic.
- R9. Claude Code module configures neovim integration (`claude-code-nvim` plugin and its Lua setup).

**OpenCode module (`home/modules/opencode/`)**
- R10. OpenCode gets its own sibling module at `home/modules/opencode/` that installs the package.
- R11. OpenCode module defines options for MCP servers, plugins, and agents. It renders merged values into `~/.config/opencode/opencode.json` and manages drop-in files in `~/.config/opencode/agents/` and `~/.config/opencode/tools/`.
- R12. OpenCode module configures custom instructions, key bindings, and agent definitions that achieve parity with Claude Code's working environment where the tool supports it.

**Codex module (`home/modules/codex/`)**
- R13. Codex gets its own sibling module at `home/modules/codex/` that installs the package.
- R14. Codex module defines options for MCP servers and skills. It renders merged values into `~/.codex/config.toml` and manages drop-in skill bundles in `~/.agents/skills/`.
- R15. Codex module configures instructions (via `AGENTS.md`), sandboxing preferences, and skill definitions that achieve parity with Claude Code's working environment where the tool supports it.

**Removed tools**
- R16. Remove aider-chat, amp-cli, goose-cli, gemini-cli packages and all their config (sops templates for `.aider.conf.yml` and `goose/config.yaml`, nvim-aider plugin and Lua setup).
- R17. Remove crush (nur.repos.charmbracelet.crush) and its sops template (`crush/crush.json`).

**Profile integration**
- R18. Profiles that currently import `ai` also import `claude-code`, `opencode`, and `codex` as sibling entries in their imports list.

---

## Success Criteria

- Running `make user` produces a working home-manager generation with all three agents installed and configured.
- Each agent module can be independently removed from a profile's imports without breaking the others or the shared `ai` module.
- MCP servers are configured once in `ai/config/mcp.nix` and consumed by all three agent modules without duplication of server definitions.
- Language and workflow modules can contribute agent-specific config (MCP servers, plugins, skills) by setting Nix options, and the agent modules merge and render them — matching the existing `programs.claude.plugins` pattern.
- No references to removed tools (aider, amp, goose, gemini-cli, crush) remain in the codebase.

---

## Scope Boundaries

- No new MCP servers or plugins are added as part of this refactor.
- Agent-specific custom instructions / agents / commands content is carried over as-is for Claude Code; opencode and codex get equivalent config where their tools support it, but no new prompt engineering.
- No changes to system-level (nix-darwin) configuration, only home-manager modules.

---

## Key Decisions

- **Sibling modules, not nested**: Agent modules are peers of `ai/` at `home/modules/`, not subdirectories within it. This keeps each agent independently importable and avoids coupling their lifecycle to the shared module.
- **Remove five tools**: aider, amp, goose, gemini-cli, and crush are all removed. Only Claude Code, opencode, and codex remain as agentic coding tools.
- **Full parity goal**: opencode and codex modules aim for equivalent config depth to Claude Code (MCP, agents/instructions, customization) rather than minimal install-only modules.
- **Nix options for cross-module composition**: All three agent modules expose `lib.mkOption`-based options (MCP servers, plugins/skills, agents) that other modules can set. This extends the pattern established by `programs.claude.plugins` to opencode and codex, giving language and workflow modules a uniform way to contribute config to any agent.
- **Shared MCP stays in ai**: The MCP server definitions remain centralized in `ai/config/mcp.nix` rather than duplicated per agent.

---

## Dependencies / Assumptions

- opencode and codex packages are available in nixpkgs (stable or unstable) or can be added to the repo's overlay/pkgs. If not packaged, planning needs to address packaging.
- opencode and codex support MCP server configuration in some form that can be wired from the shared Nix expression.
- The sops secrets for MCP servers (github token, firecrawl key, etc.) stay in `ai` since they're shared infrastructure.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R10, R13][Needs research] Are opencode and codex already packaged in nixpkgs, or do they need overlay/custom packages?
- [Affects R4, R5][Technical] What specific option types should each agent module expose? E.g. `programs.opencode.mcpServers` as `attrsOf (submodule {...})` vs `attrsOf attrs` — planning should determine the right granularity based on what each tool's config format needs.
- [Affects R7][Technical] Can the Claude Code activation scripts be simplified now that they only serve one tool?
- [Affects R11, R14][Technical] OpenCode uses `{env:VAR}` substitution in JSON config and Codex uses env var references in TOML — how should sops secrets flow into these? Options include sops templates (like today's Claude Code approach) or environment variables via shell setup.

---

## Next Steps

-> `/ce-plan` for structured implementation planning
