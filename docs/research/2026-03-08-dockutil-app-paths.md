---
date: 2026-03-08T12:00:00-05:00
researcher: Claude (Opus 4.6)
git_commit: 1fcb026c3e4a2a1dd92bba9a4b6a8910657cff5b
branch: chore/crdant/refreshes-2026-03-08
repository: crdant/dotfiles
topic: "dockutil activation script references incorrect app paths for Nix-installed and missing apps"
tags: [research, codebase, dockutil, dock, darwin, nix-apps, mas, homebrew]
status: complete
last_updated: 2026-03-08
last_updated_by: Claude (Opus 4.6)
---

# Research: dockutil Activation Script App Path Issues

**Date**: 2026-03-08T12:00:00-05:00
**Researcher**: Claude (Opus 4.6)
**Git Commit**: 1fcb026c3e4a2a1dd92bba9a4b6a8910657cff5b
**Branch**: chore/crdant/refreshes-2026-03-08
**Repository**: crdant/dotfiles

## Research Question

Why are Slack, Zoom, and Twitter not working correctly in the dockutil activation script, and how should the dock configuration reference apps installed through different mechanisms?

## Summary

The dock activation script in `home/modules/desktop/default.nix` hardcodes `/Applications/` paths for all apps, but apps installed via Nix (`environment.systemPackages`) live in `/Applications/Nix Apps/` -- or more precisely, in the Nix store at paths like `${pkgs.slack}/Applications/Slack.app`. Twitter was never installed by the configuration and has since been renamed to X. A secondary issue surfaced during the fix: `mas` 2.2.2 from stable nixpkgs lacks the `get` subcommand that Homebrew 5.0.15+ requires for `brew bundle`.

## Detailed Findings

### App Installation Mechanisms

The configuration uses three mechanisms for installing GUI applications, each placing apps in different locations:

1. **Nix packages** (`environment.systemPackages` / `home.packages`) -- Apps land in the Nix store and get symlinked to `/Applications/Nix Apps/`. Includes Slack, Zoom, Firefox, Chrome, 1Password, Bartender, Raycast, Espanso.

2. **Homebrew casks** (`homebrew.casks`) -- Apps install to `/Applications/`. Includes Ghostty, Beeper, Claude, Discord, OBS, Superhuman, Obsidian.

3. **Mac App Store** (`homebrew.masApps`) -- Apps install to `/Applications/`. Includes Todoist, Keynote, Numbers, Pages, Microsoft Office apps, Transmit.

### Dock Path Mismatches

| App | Installed Via | Actual Location | Dock Script Path | Status |
|-----|--------------|-----------------|------------------|--------|
| Slack | `pkgs.slack` in `systems/modules/desktop/default.nix:55` | `${pkgs.slack}/Applications/Slack.app` | `/Applications/Slack.app` | Wrong path |
| Zoom | `pkgs.zoom-us` in `systems/modules/desktop/default.nix:56` | `${pkgs.zoom-us}/Applications/zoom.us.app` | `/Applications/zoom.us.app` | Wrong path |
| Twitter | Not installed | Does not exist | `/Applications/Twitter.app` | Missing; renamed to X |

### Nix Store App Bundle Layout

Nix-installed macOS apps follow the pattern `${pkgs.<name>}/Applications/<BundleName>.app`:

- `${pkgs.slack}/Applications/Slack.app`
- `${pkgs.zoom-us}/Applications/zoom.us.app`

Referencing these store paths directly in the dock script eliminates dependency on the symlink location and survives store garbage collection.

### Twitter to X Rename

Twitter has been renamed to X. Available on the Mac App Store:
- **Name**: X.app
- **Mac App Store ID**: 1533525753
- **Bundle name**: `X.app`

### Missing Mac App Store Apps

Cross-referencing `mas list` against the configuration revealed several installed apps not managed by the flake:

| App | ID | Recommended Module |
|---|---|---|
| Ghostery Privacy Ad Blocker | 6504861501 | `systems/modules/desktop/default.nix` (Safari extension, alongside 1Password for Safari) |
| iMovie | 408981434 | `systems/modules/desktop/default.nix` (Apple app, alongside Keynote/Numbers/Pages) |
| Kagi for Safari | 1622835804 | `systems/modules/desktop/default.nix` (Safari extension) |
| Obsidian Web Clipper | 6720708363 | `home/users/crdant/darwin.nix` (user-specific, companion to Obsidian cask) |
| Xcode | 497799835 | `systems/modules/development/default.nix` (development tool) |
| Yubico Authenticator | 1497506650 | `systems/modules/essential-packages/default.nix` (security tool, alongside yubico-pam) |

### `mas` Version Incompatibility with Homebrew

Homebrew 5.0.15 changed `brew bundle` to call `mas get` instead of `mas install` for Mac App Store entries. The `get` subcommand was introduced in mas 3.0.0. Stable nixpkgs ships mas 2.2.2, which lacks `get`.

nix-darwin's homebrew module hardcodes `pkgs.mas` in its PATH when running `brew bundle`:
```nix
PATH="${cfg.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH"
```

Since `/opt/homebrew/bin` appears first, a stale Homebrew-installed `mas` (2.3.0) also shadows the Nix version. The solution requires both:
1. An overlay to point `pkgs.mas` at `final.unstable.mas` (5.1.0) so nix-darwin picks it up
2. Uninstalling the Homebrew `mas` formula so it doesn't shadow the Nix version

## Code References

- `home/modules/desktop/default.nix:77-124` - Dock activation script with dockutil commands
- `home/modules/desktop/default.nix:88` - Slack dock entry (wrong path)
- `home/modules/desktop/default.nix:90` - Zoom dock entry (wrong path)
- `home/modules/desktop/default.nix:91` - Twitter dock entry (not installed, wrong name)
- `systems/modules/desktop/default.nix:50-64` - Nix system packages including Slack and Zoom
- `systems/modules/desktop/default.nix:29-42` - Mac App Store apps
- `systems/modules/essential-packages/default.nix:37` - `mas` package declaration
- `overlays/default.nix:10` - `mas` overlay to unstable

## Architecture Insights

### App Path Resolution Strategy

Dock entries should use the most stable reference available for each installation mechanism:
- **Nix packages**: Use `${pkgs.<name>}/Applications/<Bundle>.app` -- survives GC and doesn't depend on symlink conventions
- **Homebrew casks**: Use `/Applications/<Bundle>.app` -- Homebrew's standard install location
- **Mac App Store**: Use `/Applications/<Bundle>.app` -- MAS standard install location
- **System apps**: Use `/System/Applications/<Bundle>.app`

### Module Organization for masApps

Mac App Store apps belong in the system module that manages related functionality:
- Safari extensions and general desktop apps in `systems/modules/desktop/`
- Development tools in `systems/modules/development/`
- Security and auth tools in `systems/modules/essential-packages/`
- User-specific companion apps in `home/users/<user>/darwin.nix`

Modules that don't natively have `masApps` need the same `supportsHomebrew` guard pattern used for `homebrew.brews` and `homebrew.casks`.

## Resolution

All issues were resolved in PR #230:
1. Slack and Zoom dock paths updated to use Nix store references
2. Twitter renamed to X and added to masApps
3. Six missing Mac App Store apps added to appropriate modules
4. Obsidian added as Homebrew cask
5. `mas` pinned to unstable via overlay for Homebrew 5.0.15+ compatibility
6. Stale Homebrew `mas` formula uninstalled manually

## Open Questions

- Should Firefox and Google Chrome (also Nix-installed) be added to the dock?
- Is Arc intentionally unmanaged by the configuration?
- Should a nix-darwin upstream issue be filed for the `mas` version pinning in the homebrew module?
