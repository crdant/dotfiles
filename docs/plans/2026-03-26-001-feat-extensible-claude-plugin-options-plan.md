---
title: "feat: Extensible Claude plugin options"
type: feat
status: completed
date: 2026-03-26
---

# feat: Extensible Claude plugin options

## Enhancement Summary

**Deepened on:** 2026-03-26
**Sections enhanced:** 7
**Research agents used:** architecture-strategist, code-simplicity-reviewer, pattern-recognition-specialist, security-sentinel, web-search-researcher, codebase-explorer

### Key Improvements
1. Corrected marketplace type design — `attrsOf str` errors on duplicate keys even with identical values; marketplaces stay centralized in AI module
2. Dropped `lib.unique` — no other list merge in the repo uses it; duplicate installs are idempotent
3. Added shell escaping requirements — `lib.escapeShellArg` and jq `--arg` for defense in depth (fixes existing bugs too)

### New Considerations Discovered
- The simplicity reviewer argues this is YAGNI for a single-maintainer dotfiles repo — the "minimal alternative" section presents a lighter option
- `types.str` does not merge even when values are identical — two modules cannot safely declare the same marketplace
- The existing activation script has unquoted Nix-to-bash interpolations (latent shell injection)
- Adding `"claude"` to `entryAfter` fixes a latent ordering bug in the current code

---

## Overview

The Claude Code plugin and marketplace configuration is hardcoded in the AI module via a static import of `config/plugins.nix`. No other home-manager module can contribute plugins. This plan introduces a custom home-manager option so any module can declare Claude plugins, and the NixOS module system merges them automatically — the same way `home.packages` or `programs.neovim.plugins` already work across modules.

## Problem Statement / Motivation

Language and tooling modules (go, python, kubernetes, etc.) already contribute packages, neovim plugins, and shell config. But if a language module wants a Claude LSP plugin for that language, the declaration must live in the AI module's `plugins.nix` rather than alongside the rest of that language's tooling. This scatters related concerns and forces the AI module to know about every language.

### Research Insights

**Counterpoint — is this worth doing?** The simplicity reviewer argues that for a single-maintainer dotfiles repo with ~13 plugins, the NixOS module option system is over-engineering. The current `plugins.nix` works, and "moving a string from one file to another" doesn't justify the structural change. This is a valid perspective — the decision depends on whether you value co-location of language tooling concerns over simplicity.

**Precedent in the repo:** Five language modules (Go, Python, JavaScript, Swift, Rust) all follow identical patterns — each contributes `home.packages`, neovim plugins, and LSP Lua config. Adding Claude plugin declarations is a natural extension of this pattern. The AI module also hardcodes LSP server paths in `crush.json` — the same extensibility problem exists there.

## Proposed Solution

Define a custom home-manager option in the AI module for plugins. Keep marketplaces centralized — they are infrastructure the AI module owns.

```nix
# NOTE: This is a custom option defined in this repo's AI module,
# not an upstream home-manager option. Any module that sets
# programs.claude.plugins must be imported alongside the AI module.
options.programs.claude = {
  plugins = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Claude Code plugins to install (format: plugin-name@marketplace)";
  };
};
```

The AI module sets its own plugin defaults and owns all marketplace configuration. Other modules contribute plugins additively. The activation script consumes the merged `config.programs.claude.plugins`.

### Research Insights

**Why no marketplace option:** `types.attrsOf types.str` does not allow multiple definitions of the same key, even with identical values. If both the Go module and AI module declared `claude-plugins-official = "anthropics/claude-plugins-official"`, Nix evaluation would fail. Since marketplaces are infrastructure (not language-specific), keeping them in the AI module avoids this entirely.

**Naming convention:** `programs.claude` is the correct namespace — home-manager uses `programs.<toolname>` for all CLI tools (`programs.git`, `programs.tmux`, `programs.neovim`). Low risk of upstream collision since a hypothetical home-manager Claude module would use different option names (`enable`, `package`, `settings`).

**Defaults mechanism:** Use `default = [...]` in the `mkOption` declaration for the AI module's base plugins. Do NOT use `mkDefault` in the config block — it would lower priority and cause language module declarations to replace rather than extend the list. `listOf` merges by concatenation at the same priority, which is the desired additive behavior.

### Minimal Alternative

If the full options approach feels too heavy, a simpler path exists:

Keep `plugins.nix` as the single source of truth. When adding a language-specific plugin, edit `plugins.nix` directly. This adds zero new code and zero new complexity. Revisit the options approach if a genuine second consumer materializes beyond "gopls-lsp might be nicer in the Go module."

## Technical Considerations

### Option definition location

Keep the option definition in the AI module. Today every profile that includes language modules also includes AI (`full.nix` and `development.nix` both import AI; `minimal.nix` and `server.nix` import neither). Extracting a standalone options module adds indirection for a coupling that doesn't exist yet. If a future profile needs language modules without AI, extract then.

This is the first custom option in any home-manager module in this repo. Add a comment at the definition site so future readers know it's custom, not upstream.

### Additive semantics (not fully declarative)

The activation script installs and updates but does not uninstall. This matches the current behavior and avoids needing to diff against `installed_plugins.json` and call `claude plugin uninstall`. Plugins removed from config persist on disk until manually removed. Document this limitation with a comment.

### Research Insights

**Security consideration:** A plugin you intend to remove (e.g., due to a vulnerability) will silently persist. For a personal dotfiles repo this is a nuisance, not a hazard. If declarative removal becomes important later, add a reconciliation step that reads `installed_plugins.json`, diffs against the declared list, and uninstalls extras.

### Deduplication — not needed

No other list merge in this repo applies deduplication (`home.packages`, `programs.neovim.plugins`, `programs.zsh.oh-my-zsh.plugins` all tolerate duplicates). If two modules declare the same plugin, the activation script runs `claude plugin update` twice — this is idempotent and harmless. Maintain single-declaration discipline instead: each plugin declared in exactly one module.

### Marketplace management stays centralized

Marketplaces remain static data in the AI module — not an option. This avoids `attrsOf str` merge conflicts and keeps infrastructure concerns separate from language-specific plugin declarations.

### Marketplace registration — keep the idempotency check

The original plan proposed always re-registering. The security review recommends keeping the skip-if-exists check: it reduces network calls during activation (fewer opportunities for MITM or DNS interference) and avoids unnecessary Git fetches. If a marketplace source URL changes, update `known_marketplaces.json` manually or add a content-addressed hash check.

### Shell escaping (fixes existing bug)

The current activation script interpolates Nix values directly into bash without quoting:

```bash
# CURRENT (unsafe):
$DRY_RUN_CMD ${claude} plugin marketplace add ${source}
$DRY_RUN_CMD ${claude} plugin install ${plugin}

# FIXED:
$DRY_RUN_CMD ${claude} plugin marketplace add ${lib.escapeShellArg source}
$DRY_RUN_CMD ${claude} plugin install ${lib.escapeShellArg plugin}
```

While current values are safe (they come from Nix expressions you control), the pattern is fragile. A marketplace source containing shell metacharacters would be interpreted by bash. Fix this regardless of whether the extensibility feature proceeds.

Similarly, jq filter interpolations should use `--arg` instead of string interpolation:

```bash
# CURRENT (fragile):
${jq} -e '.["${name}"]' "$KNOWN_MARKETPLACES"

# FIXED:
${jq} --arg name ${lib.escapeShellArg name} -e '.[$name]' "$KNOWN_MARKETPLACES"
```

### Install/update scope mismatch (fixes existing bug)

The current install/update logic (lines 114-121) checks if a plugin key exists in `installed_plugins.json` and routes to either `claude plugin install` (new) or `claude plugin update` (existing). But it doesn't check the **scope** of the installation.

**The bug:** `strategy@shortrib-labs` is installed with `"scope": "project"` (bound to `/Users/chuck/workspace/vaults/Notes`). The jq check `.plugins["strategy@shortrib-labs"]` matches this entry and takes the `update` branch. But `claude plugin update` fails because it expects a user-scoped installation — the project-scoped install from a different directory isn't updatable in this context.

**Fix options (in order of preference):**

1. **Always use `install`** — if `claude plugin install` is idempotent (upgrades existing user-scoped installs), eliminate the install/update branching entirely. Simplest approach.

2. **Filter by scope** — change the jq check to only match user-scoped installations:
   ```bash
   ${jq} --arg plugin ${lib.escapeShellArg plugin} \
     -e '.plugins[$plugin] | map(select(.scope == "user")) | length > 0' \
     "$INSTALLED_PLUGINS"
   ```

3. **Fallback on failure** — try `update` first, fall back to `install` if it fails:
   ```bash
   $DRY_RUN_CMD ${claude} plugin update ${lib.escapeShellArg plugin} 2>/dev/null \
     || $DRY_RUN_CMD ${claude} plugin install ${lib.escapeShellArg plugin}
   ```

Option 1 is preferred if `install` handles the "already installed" case gracefully. Test this manually first.

### Activation ordering

Add `"claude"` to the `entryAfter` list for `claudePlugins`. This fixes a latent ordering bug — the `claude` activation entry creates the config directory structure that `claudePlugins` depends on, but the current code doesn't express this dependency.

### Research Insights

**Error handling:** The current script silently continues on failure. Consider adding `set -euo pipefail` or per-command error checking so a typo in a plugin name doesn't pass silently. At minimum, echo warnings to stderr.

**Consolidation opportunity:** The AI module currently has two separate `programs` attribute set declarations (lines 140-155 and 321-338). The options/config refactor is a good opportunity to consolidate into a single `programs` block.

## System-Wide Impact

- **Interaction graph**: Only the `claudePlugins` activation script changes. It reads merged option values instead of importing a static file. No other activation scripts are affected.
- **Error propagation**: Plugin install failures are non-fatal today (script continues). No change to this behavior, though adding stderr warnings is recommended.
- **State lifecycle risks**: None — the activation script is purely additive and idempotent.
- **API surface parity**: No other interfaces expose plugin management.
- **Integration test scenarios**: `darwin-rebuild switch` with (a) only AI module contributing plugins, (b) multiple modules contributing plugins.

## Acceptance Criteria

- [x] `options.programs.claude.plugins` declared as `listOf str` in AI module with comment noting it's custom
- [x] AI module sets base plugins via `default = [...]` in the option declaration
- [x] Marketplace configuration stays inline in the AI module (not an option)
- [x] `config/plugins.nix` removed (values moved inline)
- [x] Activation script consumes `config.programs.claude.plugins` instead of importing `plugins.nix`
- [x] All Nix-to-bash interpolations use `lib.escapeShellArg`
- [x] jq filters use `--arg` instead of string interpolation
- [x] Install/update logic handles project-scoped vs user-scoped plugins correctly
- [x] `claudePlugins` activation depends on `"claude"` in `entryAfter`
- [x] Marketplace idempotency check preserved
- [x] At least one language module (go) declares its Claude plugin alongside its other tooling
- [x] `darwin-rebuild switch` succeeds with no behavioral change to installed plugins

## Success Metrics

Successful `darwin-rebuild switch` producing the same set of installed plugins as before, plus the Go module's plugin declaration living alongside its other Go tooling.

## Dependencies & Risks

- **`claude plugin marketplace add` idempotency**: If the CLI errors on re-add with the same source, the idempotency check remains essential. Current behavior suggests the check is correct.
- **Import coupling**: Any module setting `programs.claude.plugins` implicitly depends on the AI module being in the profile's import tree. Today this coupling exists universally. Document it.
- **Upstream namespace collision**: Low probability. An official `programs.claude` home-manager module would likely use different option names. Easy to rename if it ever happens.

## Implementation

### Phase 1: Activation script bug fixes (independent, do first)

**Files changed:**
- `home/modules/ai/default.nix` — fix shell escaping, jq interpolation, install/update scope logic, and `entryAfter` ordering

Fixes:
1. All Nix-to-bash interpolations use `lib.escapeShellArg`
2. jq filters use `--arg` instead of string interpolation
3. Install/update logic handles project-scoped plugins (currently `strategy@shortrib-labs` fails update because it's project-scoped, not user-scoped)
4. Add `"claude"` to `entryAfter` for `claudePlugins`

These fix existing bugs and are worth doing regardless of whether the extensibility feature proceeds. Can be its own commit/PR.

### Phase 2: Define option and migrate activation script

**Files changed:**
- `home/modules/ai/default.nix` — split into `options`/`config` blocks, add `options.programs.claude.plugins`, move marketplace/plugin data inline, update activation script to consume `config.programs.claude.plugins`, add `"claude"` to `entryAfter`, consolidate duplicate `programs` blocks
- `home/modules/ai/config/plugins.nix` — delete

Steps:
1. Split the module into `options` and `config` blocks (first custom option in a home module, following the `systems/modules/hardening` precedent)
2. Declare `programs.claude.plugins` with base plugins as the `default` value
3. Keep marketplace data as a `let` binding (not an option)
4. Update `claudePlugins` activation to read from `config.programs.claude.plugins`
5. Add `"claude"` to `entryAfter` (fixes latent ordering bug)
6. Delete `config/plugins.nix`

### Phase 3: Proof of concept — Go module

**Files changed:**
- `home/modules/go/default.nix` — add `programs.claude.plugins` declaration
- `home/modules/ai/default.nix` — remove `gopls-lsp` from default plugin list

Move `"gopls-lsp@claude-plugins-official"` to the Go module. The `claude-plugins-official` marketplace stays in the AI module since marketplaces are centralized infrastructure.

### Phase 4 (optional, follow-up): Migrate remaining language-specific plugins

Move `pyright-lsp`, `swift-lsp`, `typescript-lsp` to their respective language modules (Python, Swift, JavaScript — all exist). Only do this if the Go proof of concept works cleanly.

## Sources & References

### Internal References
- Existing custom option precedent: `systems/modules/hardening/default.nix`
- Homebrew merge pattern: system modules use `lib.mkMerge` with `lib.optionalAttrs supportsHomebrew`
- Implicit list merging across home modules: `home.packages`, `programs.neovim.plugins`, `programs.zsh.oh-my-zsh.plugins`
- Current plugin config: `home/modules/ai/config/plugins.nix`
- Current activation script: `home/modules/ai/default.nix:92-123`
- Language modules: `home/modules/{go,python,javascript,swift,rust}/default.nix`

### External References
- [nix.dev Module System Deep Dive](https://nix.dev/tutorials/module-system/deep-dive.html)
- [NixOS Manual: Option Types](https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html) — `listOf` merges by concatenation; `attrsOf str` errors on duplicate keys
- [NixOS RFC 0042: config-option](https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md) — `mkDefault` semantics
- [home-manager programs/tmux.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/tmux.nix) — upstream plugin management pattern
- [Developing NixOS and Home Manager Modules](https://mhu.dev/posts/2024-01-15-developing-nixos-modules/)
