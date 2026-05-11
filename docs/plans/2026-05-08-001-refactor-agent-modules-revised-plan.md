---
title: "refactor: Split ai module into per-agent modules (Updated)"
type: refactor
status: active
date: 2026-05-08
origin: docs/brainstorms/agent-module-refactor-requirements.md
---

# Split AI Module into Per-Agent Modules (Revised)

## Summary

Extract Claude Code from the monolithic `ai` module into a standalone sibling module, then create new `opencode` and `codex` modules with equivalent configuration depth. The `ai` module retains shared infrastructure (MCP server definitions, sops secrets, non-agentic packages).

**Key Discovery:** The `mcp.nix` file is already parameterized with `secretRenderer` support for multi-agent consumption. The old tools (aider, amp, goose, gemini-cli, crush) have already been removed. This is a **streamlined refactor focusing on extraction and creation** rather than removal.

---

## Problem Frame

The `ai` module currently mixes Claude Code-specific configuration (activation scripts, plugin management, neovim integration) with shared AI infrastructure. This makes it difficult to:
- Maintain per-agent configuration independently
- Add new agent modules (OpenCode, Codex) with equivalent depth
- Allow profiles to selectively include/exclude agents

The cross-module option pattern (`programs.claude.plugins`) is already established in language modules (go, development) but only Claude Code benefits from it today.

---

## Requirements

- R1. `ai` module retains non-agentic packages and shared infrastructure
- R2. `ai` module retains shared MCP config (`config/mcp.nix`) with parameterized `secretRenderer`
- R3. `ai` module retains shell environment setup that applies across agents
- R4. Each agent module defines `lib.mkOption`-based options for cross-module composition
- R5. Each agent module renders merged options into its native config format
- R6-R9. Claude Code module: package, activation scripts, plugin options, neovim integration
- R10-R12. OpenCode module: package, MCP/plugins/agents options, JSON config rendering
- R13-R15. Codex module: package, MCP/skills options, TOML config rendering
- R18. Profiles import all three agent modules as siblings to `ai`

---

## Scope Boundaries

- No new MCP servers or plugins added
- No new prompt engineering — carry over existing Claude Code agents/commands; opencode and codex get equivalent config where their tools support it
- No nix-darwin changes, only home-manager modules
- The `go` and `development` modules update their cross-module option references but their core functionality is unchanged

### Deferred to Follow-Up Work

- OpenCode agent markdown content porting from Claude Code agents
- Codex skill definitions (beyond basic structure)
- Fine-tuning `approval_policy`, `sandbox_mode`, `model` defaults for Codex based on usage

---

## Context & Research

### Current State (As of 2026-05-08)

**Already Complete:**
- `home/modules/ai/config/mcp.nix` — Already parameterized with `secretRenderer` function and `toEnvVarName` helper for multi-agent consumption
- Old agentic tools removed — No references to aider, amp, goose, gemini-cli, or crush remain

**Current `ai` module contains:**
- Claude-specific: `options.programs.claude`, packages (`claude-code`, `claude-code-transcripts`), activation scripts (`claude`, `claudeMcpServers`, `claudePlugins`), neovim plugin (`claude-code-nvim`), sops template for `mcp-servers.json`, shell env vars (`CLAUDE_CONFIG_DIR`, `ENABLE_TOOL_SEARCH`)
- Shared: Non-agentic packages (ollama, llm, mods, fabric-ai, repomix, ttok, rodney, showboat, github-mcp-server, mbta-mcp-server), llm templates, sops secrets, `config/mcp.nix`
- General neovim plugins that should move: `neo-tree-nvim`, `plenary-nvim`, `snacks-nvim`

**Cross-module pattern already established:**
- `home/modules/go/default.nix:49` — sets `programs.claude.plugins = ["gopls-lsp@claude-plugins-official"]`
- `home/modules/development/default.nix:145` — sets `programs.claude.plugins = ["compound-engineering@compound-engineering-plugin"]`

### External References

- OpenCode config: JSON at `~/.config/opencode/opencode.json`, agents in `~/.config/opencode/agents/`, supports `{env:VAR}` substitution
- Codex config: TOML at `~/.codex/config.toml`, skills in `~/.agents/skills/`, uses `env_vars` and `bearer_token_env_var` for secrets
- Both tools in nixpkgs unstable: `opencode` (v1.14.31, Bun-based), `codex` (v0.128.0, Rust-based)

---

## Key Technical Decisions

- **Parameterized mcp.nix already implemented**: The shared MCP server definitions accept a `secretRenderer` function that each agent module passes. Claude Code uses sops placeholders (default), OpenCode uses `{env:VAR}` strings, Codex uses bare env var names for `bearer_token_env_var` fields.
- **Env var naming convention**: `toEnvVarName` converts sops paths like `"firecrawl/api_key"` to `"FIRECRAWL_API_KEY"`. Defined in `mcp.nix`.
- **OpenCode config flow**: sops decrypts secrets → `programs.zsh.envExtra` exports them as env vars → `opencode.json` is generated from Nix via `xdg.configFile` with `{env:VAR}` literal strings baked in → OpenCode resolves env var references at runtime.
- **Codex config flow**: Same env var export pattern. `~/.codex/config.toml` is generated from Nix via `home.file` with env var names in `env_vars` and `bearer_token_env_var` fields. Codex resolves them at runtime.
- **Option definitions live in agent modules**: `programs.claude.*` in `claude-code/`, `programs.opencode.*` in `opencode/`, `programs.codex.*` in `codex/`. Language modules that contribute to these options must be imported alongside the agent module.
- **Neovim plugin placement**: `claude-code-nvim` moves to the claude-code module. General-purpose plugins (`neo-tree-nvim`, `plenary-nvim`, `snacks-nvim`) move to the editor module where they belong.

---

## Open Questions

### Resolved During Planning

- **Are opencode and codex packaged?** Yes, both in nixpkgs unstable. Use `unstable.opencode` and `unstable.codex`.
- **How do secrets flow to OpenCode/Codex?** Via environment variables: sops decrypts, shell config exports, tools resolve at runtime via native substitution.
- **What option types?** `attrsOf attrs` for MCP servers, `listOf str` for plugins/skills — matches the flexibility of each tool's config.
- **Is mcp.nix already parameterized?** Yes! It already has `secretRenderer` parameter and `toEnvVarName` helper.

### Deferred to Implementation

- Specific OpenCode agent markdown content — port from Claude Code agents/commands where applicable
- Exact Codex `config.toml` defaults for `approval_policy`, `sandbox_mode`, `model` — set sensible initial values and tune based on usage
- Whether `home.sessionVariables` or `programs.zsh.envExtra` is the better mechanism for exporting sops-backed env vars (try `envExtra` first since it can reference sops paths dynamically)

---

## Output Structure

```
home/modules/claude-code/
  default.nix
  config/
    commands/           (moved from ai/config/claude/commands/)
    agents/             (moved from ai/config/claude/agents/)
home/modules/opencode/
  default.nix
  config/
    agents/             (opencode agent definitions)
home/modules/codex/
  default.nix
home/modules/ai/
  default.nix           (cleaned up — shared packages, mcp.nix, sops secrets only)
  config/
    mcp.nix             (already parameterized)
    llm/templates/      (retained)
home/modules/editor/
  default.nix           (adds neo-tree-nvim, plenary-nvim, snacks-nvim)
home/profiles/
  full.nix              (imports ai, claude-code, opencode, codex)
  development.nix       (imports ai, claude-code, opencode, codex)
```

---

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce.*

```
                    ┌──────────────┐
                    │  ai module   │
                    │  (shared)    │
                    │              │
                    │ mcp.nix ─────┼──── secretRenderer parameter
                    │ sops secrets │
                    │ shell env    │
                    │ non-agentic  │
                    │ packages     │
                    └──────┬───────┘
                           │ import ../ai/config/mcp.nix
              ┌────────────┼────────────┐
              ▼            ▼            ▼
      ┌──────────────┐ ┌──────────┐ ┌──────────┐
      │ claude-code  │ │ opencode │ │  codex   │
      │              │ │          │ │          │
      │ options:     │ │ options: │ │ options: │
      │  .plugins    │ │ .mcp     │ │ .mcp     │
      │  .mcp*       │ │ .plugins │ │ .skills  │
      │              │ │ .agents  │ │          │
      │ renders →    │ │ renders →│ │ renders →│
      │ .claude.json │ │ JSON     │ │ TOML     │
      │ activation   │ │ xdg conf │ │ dotfile  │
      └──────────────┘ └──────────┘ └──────────┘
              ▲            ▲            ▲
              │   set options from      │
      ┌───────┴────────────┴────────────┴───────┐
      │     language & workflow modules          │
      │  (go, development, python, etc.)        │
      │                                         │
      │  programs.claude.plugins = [...]        │
      │  programs.opencode.mcpServers = {...}   │
      │  programs.codex.mcpServers = {...}      │
      └─────────────────────────────────────────┘
```

---

## Implementation Units

### U1. Extract claude-code module

**Goal:** Move all Claude Code-specific config from `ai/` into a new `home/modules/claude-code/` module.

**Requirements:** R6, R7, R8, R9

**Dependencies:** None (mcp.nix already parameterized)

**Files:**
- Create: `home/modules/claude-code/default.nix`
- Move: `home/modules/ai/config/claude/commands/` → `home/modules/claude-code/config/commands/`
- Move: `home/modules/ai/config/claude/agents/` → `home/modules/claude-code/config/agents/`
- Modify: `home/modules/ai/default.nix` (remove Claude-specific sections)
- Modify: `home/modules/editor/default.nix` (add neo-tree-nvim, plenary-nvim, snacks-nvim)

**Approach:**
- Move to claude-code module:
  - `options.programs.claude` definition (plugins list with defaults)
  - `home.packages`: `unstable.claude-code`, `claude-code-transcripts`
  - `home.activation`: `claude`, `claudeMcpServers`, `claudePlugins` scripts
  - `programs.neovim`: `claude-code-nvim` plugin and `require('claude-code').setup({})` lua config
  - `programs.zsh.envExtra`: CLAUDE_CONFIG_DIR and ENABLE_TOOL_SEARCH setup
  - Move `config/claude/` directory (agents and commands markdown files)
- Move general-purpose neovim plugins (`neo-tree-nvim`, `plenary-nvim`, `snacks-nvim`) to `home/modules/editor/default.nix`
- Import mcp.nix from `../ai/config/mcp.nix` with sops placeholder renderer (default behavior)
- The sops template for `mcp-servers.json` moves to this module since it's Claude-specific rendering

**Patterns to follow:**
- Module header pattern: `{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:`
- Activation DAG ordering: `lib.hm.dag.entryAfter [ "writeBoundary" ]`, `[ "sops-nix" ]`, etc.
- Neovim plugin pattern: `programs.neovim.plugins` with `lib.mkAfter` for lua config

**Test scenarios:**
- Happy path: `make user` succeeds with claude-code module imported alongside ai
- Happy path: Claude Code plugins merge from claude-code defaults + go module + development module
- Edge case: Removing claude-code from a profile's imports does not break the ai module or other agent modules
- Integration: MCP servers are still injected into `.claude.json` via the activation script

**Verification:**
- Claude Code works identically to before the refactor — same plugins, agents, commands, MCP servers
- `ai/default.nix` no longer contains Claude-specific config

---

### U2. Clean up ai module to shared-only

**Goal:** Ensure ai module contains only shared, non-agentic config after Claude Code extraction.

**Requirements:** R1, R2, R3

**Dependencies:** U1

**Files:**
- Modify: `home/modules/ai/default.nix`

**Approach:**
- Verify what remains: ollama, llm (with plugins), mods, fabric-ai, repomix, ttok, rodney, showboat, github-mcp-server, mbta-mcp-server packages
- Keep `config/mcp.nix` and sops secrets that are consumed by multiple agents
- Keep llm templates in `home.file` and `xdg.configFile`
- Remove any leftover empty sections or dead references
- Remove shell env vars that moved to claude-code module (`CLAUDE_CONFIG_DIR`, `ENABLE_TOOL_SEARCH`)
- Move `github-mcp-server` and `mbta-mcp-server` packages confirmation — they should stay as they're MCP infrastructure

**Patterns to follow:**
- Other lean modules like `home/modules/data/default.nix`

**Test scenarios:**
- Happy path: ai module imports cleanly without any agent module present
- Edge case: No orphaned sops secrets or templates referencing removed config

**Verification:**
- `ai/default.nix` contains only shared packages, mcp.nix, sops secrets, and llm templates
- No Claude Code, OpenCode, or Codex-specific config remains

---

### U3. Create opencode module

**Goal:** Install and fully configure OpenCode with MCP servers, agents, and cross-module options.

**Requirements:** R4, R5, R10, R11, R12

**Dependencies:** U2

**Files:**
- Create: `home/modules/opencode/default.nix`
- Create: `home/modules/opencode/config/agents/` (agent markdown files)

**Approach:**
- Define options:
  - `programs.opencode.mcpServers` — `attrsOf attrs`, default wired from shared mcp.nix with env var renderer
  - `programs.opencode.plugins` — `listOf str`, default empty
  - `programs.opencode.agents` — `attrsOf attrs`, for agent definitions
- Install `unstable.opencode` package
- Render merged `mcpServers` into `opencode.json` under the `"mcp"` key via `xdg.configFile`
- Use `{env:VAR}` substitution for secrets in the JSON config by passing appropriate `secretRenderer` to mcp.nix
- Export sops-backed env vars in shell config (`programs.zsh.envExtra`) for secrets referenced by MCP servers:
  - `FIRECRAWL_API_KEY`, `SHORTCUT_API_TOKEN`, `OMNI_API_TOKEN`, `GITHUB_TOKEN`, `MBTA_API_KEY`, `GOOGLE_MAPS_API_KEY`
- Place agent markdown files in `~/.config/opencode/agents/` via `xdg.configFile`
- Configure custom instructions: set `"instructions"` array in config to include `AGENTS.md` (OpenCode reads it natively as fallback from `CLAUDE.md`)
- Port applicable Claude Code agent definitions to OpenCode's markdown-with-frontmatter format

**Patterns to follow:**
- Claude Code module option pattern (from U1)
- `xdg.configFile` pattern from `home/modules/go/default.nix` (nvim lua files)
- Shell env pattern from `home/modules/ai/default.nix` (`programs.zsh.envExtra`)

**Test scenarios:**
- Happy path: `make user` succeeds with opencode module imported; `opencode.json` is generated at `~/.config/opencode/opencode.json`
- Happy path: MCP servers from shared config appear in the generated `opencode.json` with `{env:VAR}` references
- Happy path: A language module setting `programs.opencode.mcpServers.gopls = {...}` results in gopls appearing in the generated config
- Edge case: Removing opencode from profile imports does not break other modules
- Edge case: Env vars for secrets are exported in shell config

**Verification:**
- `opencode` binary is on PATH
- `~/.config/opencode/opencode.json` contains all expected MCP servers
- Agent files exist in `~/.config/opencode/agents/`

---

### U4. Create codex module

**Goal:** Install and fully configure Codex with MCP servers, skills, and cross-module options.

**Requirements:** R4, R5, R13, R14, R15

**Dependencies:** U2

**Files:**
- Create: `home/modules/codex/default.nix`

**Approach:**
- Define options:
  - `programs.codex.mcpServers` — `attrsOf attrs`, default wired from shared mcp.nix with env var name renderer
  - `programs.codex.skills` — `listOf str` or `attrsOf attrs`, for skill references
- Install `unstable.codex` package
- Render merged `mcpServers` into `~/.codex/config.toml` under `[mcp_servers.<name>]` tables
  - Use Nix's `pkgs.formats.toml` or string generation for TOML output
  - Map shared MCP config fields to Codex's schema: `command`, `args`, `env_vars`, `url`, `bearer_token_env_var`
  - For the GitHub server, use `bearer_token_env_var = "GITHUB_TOKEN"` instead of composed header
- Export sops-backed env vars in shell config for secrets (same list as OpenCode)
- Configure `AGENTS.md` at `~/.codex/AGENTS.md` with custom instructions (Codex reads this natively)
- Set sensible defaults: `approval_policy`, `sandbox_mode`, `model`
- Codex's `project_doc_fallback_filenames` can include `CLAUDE.md` for compatibility with existing repos

**Patterns to follow:**
- OpenCode module option pattern (from U3)
- TOML generation: `(pkgs.formats.toml {}).generate` or manual string building
- Sops env var export pattern (from U3)

**Test scenarios:**
- Happy path: `make user` succeeds with codex module imported; `config.toml` is generated at `~/.codex/config.toml`
- Happy path: MCP servers appear as `[mcp_servers.*]` tables in TOML with correct `env_vars` references
- Happy path: A language module setting `programs.codex.mcpServers.gopls = {...}` results in gopls appearing in the generated config
- Edge case: Removing codex from profile imports does not break other modules
- Edge case: TOML generation handles nested attributes correctly (env maps, header maps)

**Verification:**
- `codex` binary is on PATH
- `~/.codex/config.toml` contains all expected MCP servers in correct TOML format
- `~/.codex/AGENTS.md` exists with custom instructions

---

### U5. Update profiles and cross-module contributors

**Goal:** Add new agent modules to profiles and update language/workflow modules that contribute cross-module options.

**Requirements:** R4, R18

**Dependencies:** U1, U3, U4

**Files:**
- Modify: `home/profiles/full.nix`
- Modify: `home/profiles/development.nix`
- Modify: `home/modules/go/default.nix`
- Modify: `home/modules/development/default.nix`

**Approach:**
- Add `../modules/claude-code`, `../modules/opencode`, `../modules/codex` to profile imports lists (as siblings to `../modules/ai`)
- In `go/default.nix`: alongside existing `programs.claude.plugins`, add equivalent opencode and codex contributions (e.g., gopls LSP MCP server)
- In `development/default.nix`: alongside existing `programs.claude.plugins`, add equivalent opencode and codex contributions
- Keep the existing `programs.claude.plugins` references — they now resolve against the claude-code module's option definition

**Patterns to follow:**
- `home/profiles/full.nix` import list format
- `home/modules/go/default.nix:49` cross-module option pattern

**Test scenarios:**
- Happy path: `make user` succeeds for both `full` and `development` profiles
- Happy path: Go module's gopls plugin/MCP server appears in all three agents' configs
- Edge case: `minimal` and `server` profiles (which don't import ai or agent modules) still build successfully

**Verification:**
- All profiles build without errors
- Cross-module contributions from go and development modules appear in each agent's rendered config

---

## System-Wide Impact

- **Interaction graph:** Language modules (go, development) now set options across three agent modules instead of one. The Nix module system handles merging — no runtime interaction.
- **Error propagation:** If an agent module is imported without `ai` (which provides sops secrets), sops template rendering will fail at build time with a clear error about missing secrets.
- **State lifecycle risks:** None — all changes are to declarative Nix config, evaluated at build time.
- **API surface parity:** The `programs.claude.plugins` option moves from `ai` to `claude-code`. Modules that set it still work because Nix options are global — but the defining module must be imported.
- **Unchanged invariants:** The shared MCP server definitions in `ai/config/mcp.nix` remain the single source of truth. Sops secret decryption stays in the `ai` module.

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Moving `programs.claude.plugins` option from ai to claude-code could break if a module sets it without claude-code imported | Profiles that import language modules also import all agent modules — same constraint as today |
| TOML generation for Codex config may be tricky with nested MCP server attributes | Use `pkgs.formats.toml` which handles nested attrs; fall back to string generation if needed |
| OpenCode x86_64-darwin is marked broken in nixpkgs due to Bun AVX requirements | Only affects Intel Macs; current machine is Apple Silicon (sochu). Note in module with `meta.broken` check if needed |
| Rapid upstream releases of opencode/codex may cause nixpkgs version lag | Can switch to community flakes or overlay if nixpkgs falls behind |

---

## Documentation / Operational Notes

- Update any internal documentation referencing `home/modules/ai/` for Claude-specific configuration
- After deployment, verify each agent's config files are generated correctly:
  - `~/.config/claude/replicated/.claude.json` and `~/.config/claude/personal/.claude.json`
  - `~/.config/opencode/opencode.json`
  - `~/.codex/config.toml`

---

## Sources & References

- **Origin document:** [docs/brainstorms/agent-module-refactor-requirements.md](docs/brainstorms/agent-module-refactor-requirements.md)
- **Original plan (superseded):** [docs/plans/2026-05-04-001-refactor-agent-modules-plan.md](docs/plans/2026-05-04-001-refactor-agent-modules-plan.md)
- Related plan: [docs/plans/2026-03-26-001-feat-extensible-claude-plugin-options-plan.md](docs/plans/2026-03-26-001-feat-extensible-claude-plugin-options-plan.md) (established the `programs.claude.plugins` pattern)
- OpenCode docs: opencode.ai/docs/config/, opencode.ai/docs/mcp-servers/
- Codex docs: developers.openai.com/codex/cli, developers.openai.com/codex/mcp
