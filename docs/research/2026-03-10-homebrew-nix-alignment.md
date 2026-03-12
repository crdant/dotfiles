---
date: 2026-03-10T18:46:58Z
researcher: claude
git_commit: 23da83473be13f5901bd239ecde4bf734b26dda5
branch: chore/crdant/aligns-brews
repository: crdant/dotfiles
topic: "Homebrew-to-Nix configuration alignment audit for sochu"
tags: [research, codebase, homebrew, nix-darwin, package-management]
status: complete
last_updated: 2026-03-10
last_updated_by: claude
---

# Research: Homebrew-to-Nix Configuration Alignment

**Date**: 2026-03-10T18:46:58Z
**Researcher**: claude
**Git Commit**: 23da834
**Branch**: chore/crdant/aligns-brews
**Repository**: crdant/dotfiles

## Research Question

How to ensure everything installed via Homebrew on sochu is accounted for in this Nix configuration?

## Summary

There are significant gaps between what Homebrew has installed on `sochu` and what the nix-darwin configuration declares. The configuration declares Homebrew packages across 5 files that merge together for sochu's workstation role. **16 formulae, 23 taps, 17 casks, and 15 Mac App Store apps** are installed but not declared in the Nix config. Some of these are covered by equivalent Nix packages (creating overlap), while others are entirely unaccounted for.

## Recommended Approach

The most effective strategy is a three-phase audit:

### Phase 1: Capture current state

Run these commands to get the full picture:
```bash
brew leaves | sort              # explicitly installed formulae
brew list --cask | sort         # installed casks
brew tap | sort                 # active taps
mas list | sort                 # Mac App Store apps
```

### Phase 2: Cross-reference against merged config

For `sochu`, the nix-darwin homebrew config merges from these 5 sources:

| Source | File | Contributes |
|--------|------|-------------|
| essential-packages | `systems/modules/essential-packages/default.nix:8-17` | brews, masApps |
| desktop | `systems/modules/desktop/default.nix:8-47` | casks, masApps, onActivation |
| development | `systems/modules/development/default.nix:4-15` | brews, masApps |
| sochu host | `systems/hosts/sochu/default.nix:10-14` | casks |
| darwin.nix (user) | `home/users/crdant/darwin.nix:20-49` | taps, brews, casks, masApps |

### Phase 3: For each unaccounted package, decide

1. **Add to nix-darwin homebrew config** — for packages that must come from Homebrew (casks with no Nix equivalent, Mac App Store apps)
2. **Add as a Nix package** — for CLI tools available in nixpkgs (preferred for reproducibility)
3. **Remove from Homebrew** — for stale packages no longer needed
4. **Accept overlap** — some packages (like espanso, firefox) are installed both as Nix packages and Homebrew casks; decide which source of truth to use

### Consider enabling cleanup

The desktop module already has `onActivation.autoUpdate` and `onActivation.upgrade`. Adding `onActivation.cleanup = "zap"` would automatically remove any Homebrew packages not declared in the config, enforcing declarative management. **Use with caution** — test the full config first.

---

## Detailed Findings

### Formulae (brews): Installed but NOT in config

| Formula | Notes |
|---------|-------|
| `adr-tools` | Architecture decision records — no Nix equivalent |
| `chainguard-dev/tap/chainctl` | Chainguard CLI — requires tap |
| `gpgme` | GnuPG Made Easy lib — `gnupg` is in Nix, this may be a dependency |
| `imagemagick` | Image processing — available in nixpkgs |
| `johanneskaufmann/tap/html2markdown` | HTML converter — requires tap |
| `lima` | Linux VMs — already in home-manager as `unstable.lima` (`home/modules/development/default.nix:13`), Homebrew install is **redundant** |
| `mas` | Mac App Store CLI — already a Nix package in `essential-packages`, Homebrew install is **redundant** |
| `ollama` | LLM runner — available in nixpkgs |
| `opentofu` | Terraform fork — `terraform` is in Nix (`home/modules/infrastructure/default.nix:14`), decide if this replaces it |
| `osxutils` | macOS utilities — Homebrew-only |
| `oven-sh/bun/bun` | JavaScript runtime — requires tap |
| `pam_yubico` | YubiKey PAM — `yubico-pam` is a Nix package in essential-packages, **redundant** |
| `pinentry-mac` | GPG pinentry — `pinentry_mac` is a Nix package in desktop module, **redundant** |
| `pkgconf` | pkg-config — likely a build dependency |
| `tccutil` | macOS TCC database tool — Homebrew-only |
| `trash` | Move to trash — `darwin.trash` is a Nix package in essential-packages, **redundant** |

**In config but NOT installed** (config drift):
- `gogcli`, `imsg`, `peekaboo`, `sonoscli`, `summarize` (all from `darwin.nix`)

### Taps: Installed but NOT in config

Only `steipete/tap` is declared. These 23 taps are installed but undeclared:

| Tap | Used by |
|-----|---------|
| `aws/tap` | Likely stale (awscli is in Nix) |
| `buildpacks/tap` | Cloud Native Buildpacks |
| `chainguard-dev/tap` | chainctl formula |
| `cloudflare/cloudflare` | Likely stale (cloudflared is in Nix) |
| `cloudfoundry/tap` | Cloud Foundry CLI |
| `espanso/espanso` | espanso cask |
| `fermyon/tap` | Spin (fermyon-spin is in Nix home/modules/development) |
| `fluxcd/tap` | Likely stale (fluxcd is in Nix) |
| `homebrew/bundle` | Brew bundle (meta) |
| `homebrew/cask-drivers` | Hardware drivers |
| `homebrew/cask-fonts` | Font casks |
| `homebrew/cask-versions` | Alternate cask versions |
| `homebrew/services` | Brew services (meta) |
| `humanlayer/humanlayer` | HumanLayer tool |
| `johanneskaufmann/tap` | html2markdown formula |
| `k0sproject/tap` | Likely stale (k0sctl is in Nix) |
| `ojford/formulae` | Unknown |
| `oktadeveloper/tap` | Okta CLI |
| `oven-sh/bun` | Bun runtime |
| `replicatedhq/replicated` | Likely stale (replicated is custom Nix pkg) |
| `tinygo-org/tools` | TinyGo |
| `tsirysndr/tap` | Unknown |
| `vmware-tanzu/carvel` | Likely stale (carvel tools in Nix: imgpkg, kapp, vendir, ytt) |
| `vmware-tanzu/tanzu` | Tanzu CLI |

### Casks: Installed but NOT in config

| Cask | Status |
|------|--------|
| `1password` | Covered by Nix: `_1password-gui` in `home/modules/desktop/default.nix:11` |
| `bartender` | Covered by Nix: `bartender` in `systems/modules/desktop/default.nix:62` |
| `carbon-copy-cloner` | **Missing** — no Nix equivalent |
| `codelayer` | **Missing** — IDE tool |
| `codelayer-nightly` | **Missing** — IDE tool (nightly) |
| `codelayer-pro` | **Missing** — IDE tool (pro) |
| `coderabbit` | **Missing** — code review tool |
| `dash` | **Missing** — API docs browser |
| `espanso` | Covered by Nix: `espanso` in `systems/modules/desktop/default.nix:55` |
| `firefox` | Covered by Nix: `firefox` in `systems/modules/desktop/default.nix:56` |
| `font-bitstream-vera` | Covered by Nix: `bitstream-vera-sans-mono` in fonts.packages |
| `font-fira-code` | Covered by Nix: `fira-code` in fonts.packages |
| `font-inconsolata` | Covered by Nix: `inconsolata` in fonts.packages |
| `font-open-sans` | Covered by Nix: `open-sans` in `systems/modules/desktop/default.nix:58` |
| `github` | **Missing** — GitHub Desktop |
| `google-chrome` | Covered by Nix: `google-chrome` in `systems/modules/desktop/default.nix:57` |
| `gqrx` | In aguardiente/grappa config, **not sochu** |
| `grandperspective` | Covered by Nix: `grandperspective` in `systems/modules/desktop/default.nix:64` |
| `hex-fiend` | Covered by Nix: `hexfiend` in `systems/modules/desktop/default.nix:65` |
| `jetbrains-toolbox` | Covered by Nix: `jetbrains-toolbox` in `home/modules/swift/default.nix:13` |
| `microsoft-auto-update` | **Missing** — Microsoft updater |
| `microsoft-teams` | Covered by Nix: `teams` in `home/modules/replicated/default.nix:12` |
| `mitmproxy` | **Missing** — HTTPS proxy/debugger |
| `popclip` | **Missing** — text selection tool |
| `raycast` | Covered by Nix: `raycast` in `systems/modules/desktop/default.nix:67` |
| `tailscale` | Covered by Nix: `tailscale` in `systems/modules/essential-packages/default.nix:33` |
| `tailscale-app` | **Missing** — Tailscale macOS GUI app (distinct from CLI) |
| `vmware-fusion` | **Missing** — VM hypervisor |
| `yubico-yubikey-manager` | Covered by Nix: `yubikey-manager` in `home/modules/security/default.nix:20` |

**In config but NOT installed** (config drift):
- `beeper`, `discord`, `obsidian`, `repobar` (all from `darwin.nix`)

### Mac App Store: Installed but NOT in config

| App | ID | Notes |
|-----|----|-------|
| Bear | 1091189122 | Note-taking app |
| VMware Remote Console | 1230249825 | VM management |
| Paprika Recipe Manager 3 | 1303222628 | Recipe manager |
| Flighty | 1358823008 | Flight tracker |
| Twitter/X | 1482454543 | Old app ID — config has `"X" = 1533525753` (different ID) |
| Craft | 1487937127 | Document editor |
| Matter | 1548677272 | Read-later app |
| Mercury | 1621800675 | Email client |
| Kindle | 302584613 | E-reader |
| Transmit 4 | 403388562 | Older version (Transmit 5 = 1436522307 is in config) |
| Microsoft Word | 462054704 | Only Excel/PowerPoint are in config, Word is **missing** |
| GarageBand | 682658836 | Music production |
| Slack | 803453959 | Covered by Nix pkg in desktop module, not masApps |
| Buffer | 891953906 | Social media scheduler |
| TestFlight | 899247664 | App beta testing |
| Freeze | 1046095491 | In aguardiente config, **not sochu** |

**In config but NOT installed**:
- Ghostery Privacy Ad Blocker (6504861501)
- Kagi for Safari (1622835804)
- Obsidian Web Clipper (6720708363)

## Architecture Insights

### Overlap Pattern: Nix packages vs Homebrew casks

Many GUI apps are installed **both** as Nix packages and Homebrew casks. This creates ambiguity about which is the source of truth. The key overlapping packages:

- `espanso`, `firefox`, `google-chrome`, `bartender`, `grandperspective`, `hexfiend`, `raycast` — Nix system packages AND Homebrew casks
- `1password` — Nix home-manager package AND Homebrew cask
- fonts — Nix `fonts.packages` AND Homebrew font casks

**Recommendation**: For macOS GUI apps, Homebrew casks tend to be more reliable (auto-update, proper .app bundle installation, `/Applications` placement). Consider moving GUI apps to Homebrew casks and keeping CLI tools in Nix.

### Config Structure

The nix-darwin homebrew module merges `homebrew` attrs from all imported modules using `lib.mkMerge`. This is elegant but makes it hard to see the complete picture for any given host without tracing all imports. A useful debugging command:

```bash
darwin-rebuild eval --json .#darwinConfigurations.sochu.config.homebrew 2>/dev/null | jq
```

### Where to add missing packages

Following the existing patterns:
- **Host-specific casks/apps** → `systems/hosts/sochu/default.nix`
- **Common development brews** → `systems/modules/development/default.nix`
- **Common desktop casks/masApps** → `systems/modules/desktop/default.nix`
- **User-specific brews/casks** → `home/users/crdant/darwin.nix`
- **Taps needed by specific brews** → alongside the brew declaration

## Code References

- `flake.nix:82-90` — sochu darwinConfiguration definition
- `systems/hosts/sochu/default.nix:10-14` — sochu host-specific homebrew
- `systems/roles/workstation.nix` — workstation role module imports
- `systems/modules/essential-packages/default.nix:8-17` — essential brews/masApps
- `systems/modules/desktop/default.nix:8-47` — desktop casks/masApps
- `systems/modules/development/default.nix:4-15` — development brews/masApps
- `home/users/crdant/darwin.nix:20-49` — user-level taps/brews/casks/masApps

## Open Questions

1. **Overlap resolution**: Should GUI apps come from Nix packages or Homebrew casks? Having both creates confusion about which version is actually running.
2. **Stale taps**: Many taps appear to be leftovers from packages now managed by Nix. Should they be cleaned up?
3. **Config drift in darwin.nix**: Several packages declared there (gogcli, imsg, peekaboo, sonoscli, summarize, beeper, discord, obsidian, repobar) are not installed. Are these desired or should they be removed?
4. **X/Twitter ID mismatch**: Config uses ID 1533525753 ("X") but installed is 1482454543 ("Twitter"). The app may have changed its App Store ID during rebrand.
5. **onActivation.cleanup**: Would adding `cleanup = "zap"` be desirable to enforce declarative management, or would it be too aggressive?
