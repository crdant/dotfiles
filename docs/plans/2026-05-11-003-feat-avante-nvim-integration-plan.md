---
status: completed
created: 2026-05-11
---

# Add Avante.nvim to AI Module

## Problem Frame

The user wants to integrate [Avante.nvim](https://github.com/yetone/avante.nvim) — a Neovim plugin that emulates the Cursor AI IDE — into their dotfiles' AI home-manager module (`home/modules/ai/`). Avante.nvim provides AI-powered code assistance directly within Neovim, offering an experience similar to Cursor's AI chat and code generation features.

Currently, the `ai` module contains non-agentic shared AI tools (ollama, llm, mods, fabric-ai, etc.) but has no Neovim integration. Adding Avante.nvim will bring AI-assisted editing capabilities into the editor, complementing the existing OpenCode agent workflow rather than replacing it.

## Scope Boundaries

### In Scope
- Install `avante-nvim` and its required dependencies via the `ai` home-manager module
- Configure Avante.nvim with sensible defaults that work alongside OpenCode
- Use Moonshot (Kimi) as the default provider (user preference)
- Integrate with existing editor tooling (snacks.nvim input, fzf/telescope file selection)
- Add required dependency plugins (`nui.nvim`, `render-markdown.nvim`)

### Deferred for Later
- Custom keybinding overrides (user can extend via personal config)
- Advanced provider configurations beyond Moonshot (e.g., Claude, OpenAI)
- Custom prompts or shortcuts definitions
- Avante.nvim build-from-source configuration (use prebuilt binary)

### Outside This Product's Identity
- Replacing OpenCode with Avante.nvim as primary agent
- Adding Avante.nvim to non-AI profiles (minimal, server)
- Configuring Avante.nvim as a standalone agent CLI (Zen mode is out of scope)

## Requirements Traceability

| Requirement | Source | Implementation |
|---|---|---|
| Install Avante.nvim | Feature request | U1: Add package and dependencies |
| Rational defaults for OpenCode | Feature request | U2: Lua configuration |
| Use Kimi as AI provider | User request | U2: Moonshot provider, new SOPS secret |
| No conflict with OpenCode | Implicit | U2: Separate keybindings, scoped API keys |

## Key Technical Decisions

**1. Module placement: `home/modules/ai/default.nix`**
Rationale: The user explicitly requested the "AI home manager module." While Avante.nvim is agentic in nature, it serves as an editor-embedded AI assistant rather than a standalone agent like OpenCode or Claude Code. The `ai` module is the shared AI infrastructure module, and Avante.nvim complements all agent workflows rather than belonging to one specific agent module.

**2. Default provider: Moonshot (Kimi)**
Rationale: The user explicitly requested Kimi as the AI model for Avante.nvim. Moonshot AI provides the Kimi model family through their API. This requires adding a new SOPS-managed secret for the Moonshot API key, but aligns with the user's stated preference.

**3. Input provider: `snacks`**
Rationale: The editor module already installs and configures `snacks.nvim`. Using snacks as the input provider provides a consistent UI experience without adding new dependencies.

**4. File selector: `fzf`**
Rationale: The editor module already has `fzf-vim` configured. Using fzf-lua or native fzf integration provides consistent file selection.

**5. API key strategy: Scoped `AVANTE_MOONSHOT_API_KEY`**
Rationale: Avante.nvim supports scoped API keys (prefixed with `AVANTE_`) to avoid conflicts with other tools. We will set `AVANTE_MOONSHOT_API_KEY` in shell environment using a new SOPS-managed secret. This isolates Avante.nvim's Kimi API key from other tools and follows the same pattern used for OpenCode secrets.

## Implementation Units

### U1. Add Avante.nvim Package and Dependencies

**Goal:** Install `avante-nvim` and its required dependency plugins in the AI module.

**Requirements:** Install Avante.nvim

**Dependencies:** None

**Files:**
- `home/modules/ai/default.nix`

**Approach:**
Add Neovim plugin configuration to the `ai` module. The module currently has no `programs.neovim` section, so this is a new addition.

Required packages to add (declare in this order to ensure dependency loading):
- `pkgs.vimPlugins.nui-nvim` (required dependency — must load before avante)
- `pkgs.vimPlugins.render-markdown-nvim` (required dependency for rendering — must load before avante)
- `pkgs.vimPlugins.avante-nvim` (main plugin)

Optional but recommended:
- `pkgs.vimPlugins.img-clip-nvim` (image paste support)

The `ai` module should declare `programs.neovim.plugins` and `programs.neovim.extraLuaConfig`. Use `lib.mkAfter` for the Lua config to ensure it loads after the base editor configuration.

**Patterns to follow:**
- See `home/modules/claude/default.nix:148-158` for agent-specific Neovim plugin pattern
- See `home/modules/editor/default.nix:14-161` for core editor plugin declarations

**Test scenarios:**
- Happy path: `home-manager switch` succeeds without errors
- Integration: Neovim starts without plugin load errors (`nvim --headless -c 'qa'`)
- Integration: Avante initializes correctly (`nvim --headless -c 'lua require("avante").setup({})' -c 'qa'`)
- Verification: `:checkhealth avante` shows required dependencies satisfied

---

### U2. Configure Avante.nvim with OpenCode-Friendly Defaults

**Goal:** Add Lua configuration for Avante.nvim that integrates well with the existing dotfiles setup and OpenCode workflow.

**Requirements:** Rational defaults for OpenCode

**Dependencies:** U1

**Files:**
- `home/modules/ai/default.nix` (Lua config addition)

**Approach:**
Add `programs.neovim.extraLuaConfig` with Avante.nvim setup:

1. **Provider configuration:** Use Moonshot (Kimi) with the latest K2 model, pointing to the Moonshot API endpoint
2. **Input provider:** Use `snacks` (already installed in editor module)
3. **File selector:** Use `fzf` (already available via fzf-vim)
4. **Keymap prefix:** Use `<leader>a` (consistent with Avante defaults, doesn't conflict with OpenCode)
5. **Window position:** `right` (standard sidebar position)
6. **Auto-suggestions:** Disabled by default (avoid conflicts with supermaven-nvim in editor module)
7. **Instructions file:** `avante.md` (default, for project-specific prompts)
8. **Behaviour settings:** Enable token counting, auto-add current file, use inline buttons for confirmation

**Environment variables:**
Add `AVANTE_MOONSHOT_API_KEY` to shell environment using a new SOPS secret. Add `moonshot/apiKey` to the `ai` module's SOPS secrets declaration and reference it via `config.sops.secrets."moonshot/apiKey".path`, matching the pattern used for OpenCode secrets in `home/modules/opencode/default.nix:103-111`.

**New SOPS secret required:**
- Add `moonshot/apiKey` to `home/modules/ai/default.nix` sops.secrets
- The implementer must add the corresponding secret to their SOPS-encrypted secrets file (e.g., `home/users/crdant/secrets.yaml`)

**Lua configuration pattern:**
Follow the `lib.mkAfter` pattern from `home/modules/claude/default.nix:154` to ensure Avante loads after core editor setup.

**Technical design (directional guidance):**
```lua
-- This illustrates the intended configuration approach
require('avante').setup({
  provider = "moonshot",
  auto_suggestions_provider = "moonshot",
  providers = {
    moonshot = {
      endpoint = "https://api.moonshot.ai/v1",
      model = "kimi-k2-0711-preview",  -- Update to latest Kimi model as of implementation date
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 32768,
      },
    },
  },
  input = {
    provider = "snacks",
    provider_opts = {
      title = "Avante Input",
      icon = " ",
    },
  },
  selector = {
    provider = "fzf",  -- Use "fzf_lua" if fzf-lua is installed; "fzf" for fzf-vim
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    enable_token_counting = true,
    auto_add_current_file = true,
    auto_approve_tool_permissions = true,
    confirmation_ui_style = "inline_buttons",
  },
  windows = {
    position = "right",
    width = 30,
    input = {
      prefix = "> ",
      height = 8,
    },
  },
})
```

**Patterns to follow:**
- `home/modules/claude/default.nix:148-158` for agent neovim plugin + Lua config
- `home/modules/opencode/default.nix:103-111` for SOPS secret environment variable pattern
- `home/modules/opencode/default.nix:114-123` for fish shell equivalent

**Test scenarios:**
- Happy path: `:AvanteAsk` opens the sidebar without errors
- Integration: Avante sidebar renders markdown correctly (requires render-markdown-nvim)
- Integration: File selector works with fzf (`@file` mention triggers fzf)
- Integration: Input dialog uses snacks UI
- Error path: Graceful handling when `AVANTE_MOONSHOT_API_KEY` is unset (Avante prompts for key)
- Edge case: Multiple Neovim plugin configs merge correctly (base + editor + ai + claude module)

**Verification:**
- `darwin-rebuild switch` or `home-manager switch` succeeds
- `nvim --headless -c 'qa'` exits without errors
- Open Neovim, verify `:AvanteAsk` opens sidebar
- Verify `<leader>aa` keybinding works
- Check that existing OpenCode workflow is unaffected

## Deferred Questions

- **Q1: Should Avante.nvim be added to specific profiles only?** The `ai` module is already imported by `full.nix` and `development.nix` profiles. No action needed unless user wants to restrict it.
- **Q2: Should we enable auto-suggestions?** Currently set to `false` to avoid conflict with `supermaven-nvim` in the editor module. Can be enabled later if user prefers Avante suggestions over Supermaven.

## Dependencies / Prerequisites

- `avante-nvim` must be available in nixpkgs (confirmed: `vimPlugins.avante-nvim` exists in unstable)
- Neovim 0.11+ (the dotfiles already use a recent Neovim version)
- Existing `snacks.nvim` in editor module (confirmed in `home/modules/editor/default.nix`)
- Existing `fzf-vim` in editor module (confirmed in `home/modules/editor/default.nix`)
- New Moonshot API key SOPS secret must be added to `home/modules/ai/default.nix` and the user's encrypted secrets file
- Existing SOPS infrastructure (confirmed in `home/modules/ai/default.nix`)

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `avante-nvim` nixpkgs version is outdated | Low | Medium | Check version on install; if too old, consider overlay or build from source |
| Lua config conflicts with existing plugins | Medium | Low | Use `lib.mkAfter` to load after base config; test `:checkhealth` |
| API key environment variable conflicts | Low | Medium | Use scoped `AVANTE_MOONSHOT_API_KEY` to isolate from other tools |
| Neovim startup time increase | Low | Low | Avante is lazy-loaded by default; minimal impact |

## Documentation Plan

- Add a brief comment in `home/modules/ai/default.nix` explaining the Avante.nvim configuration
- The `avante.md` file convention for project-specific instructions is documented upstream; no additional docs needed

## Success Criteria

1. `home-manager switch` completes without errors
2. Neovim starts and Avante.nvim loads (`:AvanteAsk` works)
3. Avante sidebar opens with Kimi (Moonshot) provider configured
4. File selector, input UI, and markdown rendering function correctly
5. Existing OpenCode workflow remains unaffected
6. Moonshot API key is sourced from SOPS secrets without manual configuration (secret must be added to encrypted secrets file before deployment)
