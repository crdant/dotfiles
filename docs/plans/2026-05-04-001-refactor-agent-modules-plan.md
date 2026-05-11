---
title: "refactor: Split ai module into per-agent modules"
type: refactor
status: active
date: 2026-05-04
origin: docs/brainstorms/agent-module-refactor-requirements.md
---

# Split AI Module into Per-Agent Modules

## Overview

Extract Claude Code, OpenCode, and Codex into independent sibling modules under `home/modules/`, remove five unused agentic tools, and establish a cross-module Nix option pattern so language and workflow modules can contribute config to any agent.

---

## Problem Frame

The `ai` module is a monolith mixing six agentic coding tools with shared AI utilities. Only three agents are actively wanted, each needing full-depth config. Dead tool config accumulates and per-agent config is hard to maintain. (see origin: `docs/brainstorms/agent-module-refactor-requirements.md`)

---

## Requirements Trace

- R1. ai module retains non-agentic packages and llm templates
- R2. ai module retains shared MCP config and sops secrets
- R3. ai module retains shell environment setup
- R4. Each agent module defines `lib.mkOption`-based options for cross-module composition
- R5. Each agent module renders merged options into its native config format
- R6-R9. Claude Code module: package, activation scripts, plugin options, neovim integration
- R10-R12. OpenCode module: package, MCP/plugins/agents options, config rendering
- R13-R15. Codex module: package, MCP/skills options, TOML rendering, AGENTS.md
- R16. Remove aider, amp, goose, gemini-cli and all their config
- R17. Remove crush and its sops template
- R18. Profiles import all three agent modules as siblings

---

## Scope Boundaries

- No new MCP servers or plugins added
- No new prompt engineering — carry over existing Claude Code agents/commands; opencode and codex get equivalent config where their tools support it
- No nix-darwin changes, only home-manager modules
- The `go` and `development` modules update their cross-module option references but their core functionality is unchanged

---

## Context & Research

### Relevant Code and Patterns

- `home/modules/ai/default.nix` — current monolith (option definitions, packages, activation scripts, sops templates, neovim config)
- `home/modules/ai/config/mcp.nix` — shared MCP server definitions as a pure Nix function
- `home/modules/go/default.nix:49` — cross-module plugin contribution pattern (`programs.claude.plugins = [...]`)
- `home/modules/development/default.nix:145` — same cross-module pattern
- `home/modules/editor/default.nix` — neovim plugin/lua config pattern with `lib.mkAfter`
- `home/modules/replicated/default.nix` — sops template pattern reference
- `home/profiles/full.nix` — profile import list pattern
- `overlays/default.nix` — overlay structure (vim plugin overlays)

### External References

- OpenCode config: JSON at `~/.config/opencode/opencode.json`, agents in `~/.config/opencode/agents/`, supports `{env:VAR}` substitution
- Codex config: TOML at `~/.codex/config.toml`, skills in `~/.agents/skills/`, uses `env_vars` and `bearer_token_env_var` for secrets
- Both tools in nixpkgs unstable: `opencode` (v1.14.31, Bun-based), `codex` (v0.128.0, Rust-based)

---

## Key Technical Decisions

- **Parameterized secret rendering in mcp.nix**: `mcp.nix` accepts a `secretRenderer` function parameter. The renderer returns the secret value only — composition (like `"Bearer " + secret`) happens at the call site in `mcp.nix`. Each agent passes its own renderer:
  - Claude Code: `path: config.sops.placeholder.${path}` → sops substitutes the actual secret into the template
  - OpenCode: `path: "{env:${toEnvVarName path}}"` → OpenCode resolves `{env:GITHUB_TOKEN}` at runtime
  - Codex: `path: toEnvVarName path` → used in `bearer_token_env_var` and `env_vars` fields
  - The GitHub server's `Authorization` header composes at the call site: `"Bearer ${secretRenderer "github/token"}"` — this produces `"Bearer <sops-placeholder>"` for Claude Code and `"Bearer {env:GITHUB_TOKEN}"` for OpenCode. For Codex, the GitHub server uses `bearer_token_env_var = "GITHUB_TOKEN"` instead of a composed header, so the Codex transformation handles this case separately.
- **Env var naming convention**: `toEnvVarName` converts sops paths to env var names by replacing `/` with `_` and uppercasing. Examples: `"firecrawl/api_key"` → `FIRECRAWL_API_KEY`, `"github/token"` → `GITHUB_TOKEN`, `"google/maps/apiKey"` → `GOOGLE_MAPS_APIKEY`. This helper is defined in `mcp.nix` alongside the server definitions.
- **OpenCode config flow**: sops decrypts secrets → `programs.zsh.envExtra` exports them as env vars (e.g., `export FIRECRAWL_API_KEY="$(cat ${sopsSecretPath})"`) → `opencode.json` is generated from Nix via `xdg.configFile` with `{env:VAR}` literal strings baked in → OpenCode resolves env var references at runtime. No sops template needed for `opencode.json` itself.
- **Codex config flow**: Same env var export pattern as OpenCode. `~/.codex/config.toml` is generated from Nix via `home.file` with env var names in `env_vars` and `bearer_token_env_var` fields. Codex resolves them at runtime.
- **`attrsOf attrs` for MCP server options**: Flexible enough for any tool's schema without over-specifying a submodule type. Each agent module validates by rendering to its native format. Defaults come from shared `mcp.nix`; language modules extend or override individual servers.
- **Option definitions live in agent modules**: `programs.claude.*` in `claude-code/`, `programs.opencode.*` in `opencode/`, `programs.codex.*` in `codex/`. Language modules that contribute to these options must be imported alongside the agent module (same constraint as today).
- **Neovim plugin placement**: `claude-code-nvim` moves to the claude-code module. General-purpose plugins currently bundled in `ai` (`neo-tree-nvim`, `plenary-nvim`, `snacks-nvim`) move to the editor module where they belong. `nvim-aider` is removed entirely.
- **Neovim overlay cleanup**: Remove the `nvim-aider` overlay entry when removing aider.

---

## Open Questions

### Resolved During Planning

- **Are opencode and codex packaged?** Yes, both in nixpkgs unstable. Use `unstable.opencode` and `unstable.codex`.
- **How do secrets flow to OpenCode/Codex?** Via environment variables: sops decrypts, shell config exports, tools resolve at runtime via native substitution.
- **What option types?** `attrsOf attrs` for MCP servers, `listOf str` for plugins/skills — matches the flexibility of each tool's config.

### Deferred to Implementation

- Specific OpenCode agent markdown and Codex skill markdown content — port from Claude Code agents/commands where applicable
- Whether `home.sessionVariables` or `programs.zsh.envExtra` is the better mechanism for exporting sops-backed env vars (try `envExtra` first since it can reference sops paths dynamically)
- Exact Codex `config.toml` defaults for `approval_policy`, `sandbox_mode`, `model` — set sensible initial values and tune based on usage

---

## Output Structure

```
home/modules/claude-code/
  default.nix
  config/claude/
    agents/           (moved from ai/config/claude/agents/)
    commands/         (moved from ai/config/claude/commands/)
home/modules/opencode/
  default.nix
  config/
    agents/           (opencode agent definitions)
home/modules/codex/
  default.nix
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

- [ ] U1. **Strip removed tools from ai module**

**Goal:** Remove aider, amp, goose, gemini-cli, and crush — packages, configs, sops templates, neovim plugins, and overlay entries.

**Requirements:** R16, R17

**Dependencies:** None

**Files:**
- Modify: `home/modules/ai/default.nix`
- Modify: `overlays/default.nix` (remove nvim-aider entry)
- Delete: `overlays/nvim-aider/` (entire directory)

**Approach:**
- Remove from `home.packages`: `aider-chat`, `amp-cli`, `goose-cli`, `gemini-cli`, `nur.repos.charmbracelet.crush`
- Remove sops templates: `.aider.conf.yml`, `crush/crush.json`, `goose/config.yaml`
- Remove sops secrets only used by removed tools (check for shared usage first)
- Remove neovim plugins: `nvim-aider` and its `require('nvim_aider').setup({})` lua config
- Remove `nvim-aider` from `overlays/default.nix` modifications overlay
- Delete `overlays/nvim-aider/` directory

**Patterns to follow:**
- Existing module structure in `home/modules/ai/default.nix`

**Test scenarios:**
- Happy path: `make user` succeeds after removing all five tools and their config
- Edge case: No dangling references — grep codebase for `aider`, `amp-cli`, `goose`, `gemini-cli`, `crush`, `GOOSE_`, `nvim-aider`, `nvim_aider` returns zero hits in `.nix` files, activation scripts, and shell config

**Verification:**
- `home-manager switch` completes without errors
- No references to removed tools remain in any `.nix` file

---

- [ ] U2. **Refactor mcp.nix for multi-agent consumption**

**Goal:** Parameterize `mcp.nix` so each agent module can render secrets in its native format while sharing server definitions.

**Requirements:** R2, R4, R5

**Dependencies:** U1

**Files:**
- Modify: `home/modules/ai/config/mcp.nix`

**Approach:**
- Add a `secretRenderer` function parameter (default: sops placeholder for backward compatibility)
- For each MCP server that uses secrets, replace direct `config.sops.placeholder.*` references with `secretRenderer "sops/path"` calls
- The GitHub server's `Authorization = "Bearer ${secret}"` pattern needs the renderer to handle composed values — either pass the composition to the renderer or let the renderer return just the secret and handle composition at the call site
- Define a helper function `toEnvVarName` that converts sops paths like `"firecrawl/api_key"` to env var names like `"FIRECRAWL_API_KEY"`

**Patterns to follow:**
- Current `mcp.nix` structure (pure function taking `{ config, pkgs }`)

**Test scenarios:**
- Happy path: Calling mcp.nix with no secretRenderer uses sops placeholders (backward compatible with Claude Code)
- Happy path: Calling mcp.nix with an env var renderer produces `{env:FIRECRAWL_API_KEY}` style references
- Edge case: GitHub server's composed `Authorization` header renders correctly in all three modes

**Verification:**
- Claude Code's existing MCP injection still works identically after this change
- The function signature is documented with a comment explaining the renderer parameter

---

- [ ] U3. **Extract claude-code module**

**Goal:** Move all Claude Code-specific config from `ai/` into a new `home/modules/claude-code/` module.

**Requirements:** R6, R7, R8, R9

**Dependencies:** U1, U2

**Files:**
- Create: `home/modules/claude-code/default.nix`
- Move: `home/modules/ai/config/claude/` → `home/modules/claude-code/config/claude/`
- Modify: `home/modules/ai/default.nix` (remove extracted sections)
- Modify: `home/modules/editor/default.nix` (add neo-tree-nvim, plenary-nvim, snacks-nvim)

**Approach:**
- Move to claude-code module:
  - `options.programs.claude` definition (plugins list with defaults)
  - `home.packages`: `unstable.claude-code`, `claude-code-transcripts`
  - `home.activation`: `claude`, `claudeMcpServers`, `claudePlugins` scripts
  - `programs.neovim`: `claude-code-nvim` plugin and `require('claude-code').setup({})` lua config
  - `programs.zsh.envExtra`: CLAUDE_CONFIG_DIR and ENABLE_TOOL_SEARCH setup
  - Move `config/claude/` directory (agents and commands markdown files)
- Move general-purpose neovim plugins (`neo-tree-nvim`, `plenary-nvim`, `snacks-nvim`) to `home/modules/editor/default.nix` — they're editor infrastructure, not Claude-specific
- Import mcp.nix from `../ai/config/mcp.nix` with sops placeholder renderer
- The sops template for `mcp-servers.json` moves to this module since it's Claude-specific rendering
- Keep `home/modules/ai/config/mcp.nix` in place as the shared definition

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

- [ ] U4. **Clean up ai module to shared-only**

**Goal:** Ensure ai module contains only shared, non-agentic config after Claude Code extraction.

**Requirements:** R1, R2, R3

**Dependencies:** U3

**Files:**
- Modify: `home/modules/ai/default.nix`

**Approach:**
- Verify what remains: ollama, llm (with plugins), mods, fabric-ai, repomix, ttok, rodney, showboat, github-mcp-server, mbta-mcp-server packages
- Keep `config/mcp.nix` and sops secrets that are consumed by multiple agents
- Keep llm templates in `home.file` and `xdg.configFile`
- Remove any leftover empty sections or dead references
- Move `github-mcp-server` and `mbta-mcp-server` packages here since they're MCP infrastructure, not agent-specific

**Patterns to follow:**
- Other lean modules like `home/modules/data/default.nix`

**Test scenarios:**
- Happy path: ai module imports cleanly without any agent module present
- Edge case: No orphaned sops secrets or templates referencing removed config

**Verification:**
- `ai/default.nix` contains only shared packages, mcp.nix, sops secrets, shell env, and llm templates
- No Claude Code, OpenCode, or Codex-specific config remains

---

- [ ] U5. **Create opencode module**

**Goal:** Install and fully configure OpenCode with MCP servers, agents, and cross-module options.

**Requirements:** R4, R5, R10, R11, R12

**Dependencies:** U2, U4

**Files:**
- Create: `home/modules/opencode/default.nix`
- Create: `home/modules/opencode/config/agents/` (agent markdown files)

**Approach:**
- Define options:
  - `programs.opencode.mcpServers` — `attrsOf attrs`, default wired from shared mcp.nix with env var renderer
  - `programs.opencode.plugins` — `listOf str`, default empty
  - `programs.opencode.agents` — `attrsOf attrs`, for agent definitions
- Install `unstable.opencode` package
- Render merged `mcpServers` into `opencode.json` under the `"mcp"` key via `xdg.configFile` or sops template
- Use `{env:VAR}` substitution for secrets in the JSON config
- Export sops-backed env vars in shell config (`programs.zsh.envExtra`) for secrets referenced by MCP servers
- Place agent markdown files in `~/.config/opencode/agents/` via `xdg.configFile`
- Configure custom instructions: set `"instructions"` array in config to include `AGENTS.md` (OpenCode reads it natively as fallback from `CLAUDE.md`)
- Port applicable Claude Code agent definitions to OpenCode's markdown-with-frontmatter format

**Patterns to follow:**
- Claude Code module option pattern (from U3)
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

- [ ] U6. **Create codex module**

**Goal:** Install and fully configure Codex with MCP servers, skills, and cross-module options.

**Requirements:** R4, R5, R13, R14, R15

**Dependencies:** U2, U4

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
- Export sops-backed env vars in shell config for secrets
- Configure `AGENTS.md` at `~/.codex/AGENTS.md` with custom instructions (Codex reads this natively)
- Set sensible defaults: `approval_policy`, `sandbox_mode`, `model`
- Codex's `project_doc_fallback_filenames` can include `CLAUDE.md` for compatibility with existing repos

**Patterns to follow:**
- OpenCode module option pattern (from U5)
- TOML generation: `(pkgs.formats.toml {}).generate` or manual string building
- Sops env var export pattern (from U5)

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

- [ ] U7. **Update profiles and cross-module contributors**

**Goal:** Add new agent modules to profiles and update language/workflow modules that contribute cross-module options.

**Requirements:** R4, R18

**Dependencies:** U3, U5, U6

**Files:**
- Modify: `home/profiles/full.nix`
- Modify: `home/profiles/development.nix`
- Modify: `home/modules/go/default.nix`
- Modify: `home/modules/development/default.nix`

**Approach:**
- Add `../modules/claude-code`, `../modules/opencode`, `../modules/codex` to profile imports lists
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

## Sources & References

- **Origin document:** [docs/brainstorms/agent-module-refactor-requirements.md](docs/brainstorms/agent-module-refactor-requirements.md)
- Related plan: [docs/plans/2026-03-26-001-feat-extensible-claude-plugin-options-plan.md](docs/plans/2026-03-26-001-feat-extensible-claude-plugin-options-plan.md) (established the `programs.claude.plugins` pattern)
- OpenCode docs: opencode.ai/docs/config/, opencode.ai/docs/mcp-servers/
- Codex docs: developers.openai.com/codex/cli, developers.openai.com/codex/mcp
