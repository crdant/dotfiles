---
title: "feat: Deploy home-manager flake to fresh Ubuntu VM"
type: feat
status: active
date: 2026-04-16
---

# Deploy home-manager flake to fresh Ubuntu VM

## Overview

Replicate the `mash` system's user environment on a fresh Ubuntu 24.04 VM by applying the `crdant` homeConfiguration with the `full` profile using Determinate Nix. Since this is Ubuntu (not NixOS), only the home-manager layer applies — system-level config (firewall, systemd-networkd, SSH server, CA certs, sudo) stays outside Nix.

## Problem Statement

The `mash` NixOS system bundles two layers: system-level (`nixosConfiguration`) and user-level (standalone `homeConfigurations`). On a non-NixOS Ubuntu VM, only the user-level layer can be applied directly. Several obstacles stand between the current flake and a clean `home-manager switch` on x86_64-linux:

1. **Overlays break on Linux** — `mas` and `container` don't exist in nixpkgs for Linux
2. **`nixpkgs-25.11-darwin` branch** — may yield poor binary cache hits on Linux
3. **`builtins.currentSystem`** — requires `--impure` (works on-VM, not cross-platform)
4. **GUI packages in `full` profile** — neovide, spotify, obsidian are useless on headless VM
5. **SOPS/GPG bootstrap** — secrets can't decrypt without the private key
6. **Swift module** — `sourcekit.lua` unconditionally calls `xcrun` (macOS-only)
7. **1Password SSH agent paths** — hardcoded to macOS in homelab/home-network modules

## Proposed Solution

A two-pass approach:

**Pass 1: Bootstrap** — Install Determinate Nix, apply `minimal` or `server` profile to get a working shell, import GPG keys.

**Pass 2: Full deployment** — After fixing the platform blockers in the flake, apply the `full` profile.

The flake fixes are small and scoped — guard Darwin-only overlays by platform, guard the sourcekit lua config, and optionally make 1Password agent paths platform-aware.

## Technical Approach

### Phase 1: Fix Flake Platform Blockers

These changes are required before `home-manager switch --flake .#crdant --impure` can succeed on x86_64-linux.

#### 1a. Guard Darwin-only overlays

`overlays/default.nix` — the `mas` and `container` overrides fail on Linux because those packages don't exist in nixpkgs for x86_64-linux.

```nix
# overlays/default.nix — modifications overlay
modifications = final: prev: {
  # mas is macOS-only (Mac App Store CLI)
  mas = if final.stdenv.isDarwin then final.unstable.mas else prev.mas or null;

  # container is Apple's container runtime — macOS only
  container = if final.stdenv.isDarwin then prev.container.overrideAttrs (oldAttrs: rec {
    version = "0.10.0";
    src = prev.fetchurl {
      url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
      hash = "sha256-xIHONVUk0DbDzdrH/SgeMXlNQGkL+aIfcy7z12+p/gg=";
    };
  }) else prev.container or null;

  # ... rest stays the same
};
```

Also check whether `mlx-lm` in `python3Packages` is Apple Silicon only — if so, guard it similarly.

#### 1b. Guard Swift module's sourcekit.lua

`home/modules/swift/default.nix:27-29` — wrap with platform check:

```nix
extraLuaConfig = lib.mkIf isDarwin (lib.mkAfter ''
  require('sourcekit')
'');
```

#### 1c. (Optional) Platform-aware 1Password agent paths

In `home/modules/homelab/default.nix` and `home/modules/home-network/default.nix`, make the `identityAgent` path conditional:

```nix
identityAgent = if isDarwin
  then "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  else "~/.1password/agent.sock";
```

This is optional if 1Password isn't installed on the VM — the SSH configs will just be present but the agent won't connect.

### Phase 2: Bootstrap the Ubuntu VM

Run these steps on the VM via SSH.

#### 2a. Install prerequisites on minimized Ubuntu

```bash
sudo apt update && sudo apt install -y curl git
```

#### 2b. Install Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Determinate Nix enables flakes and the unified CLI by default — no extra config needed.

Source the Nix profile:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

#### 2c. First pass — apply minimal profile to get a working shell

```bash
nix run home-manager -- switch --flake github:crdant/dotfiles#crdant:minimal --impure
```

This gives you zsh, neovim, tmux, fzf, direnv, and core tools without hitting any of the platform issues in the larger profiles (assuming overlay fixes from Phase 1 are pushed).

#### 2d. Bootstrap GPG keys

Transfer GPG private key to the VM for SOPS decryption and Git commit signing:

```bash
# From your macOS machine:
gpg --export-secret-keys 0805EEDF0FEA6ACD | ssh crdant@<vm-ip> gpg --import

# On the VM, trust the key:
echo "0805EEDF0FEA6ACD:6:" | gpg --import-ownertrust
```

If using a YubiKey, you can forward the GPG agent over SSH instead:

```bash
ssh -R /run/user/1001/gnupg/S.gpg-agent:/Users/crdant/.gnupg/S.gpg-agent.extra crdant@<vm-ip>
```

#### 2e. Set login shell to zsh

```bash
sudo chsh -s $(which zsh) crdant
```

### Phase 3: Full Deployment

After Phase 1 fixes are pushed and GPG keys are in place:

```bash
home-manager switch --flake github:crdant/dotfiles#crdant --impure
```

This applies the `full` profile. Note:
- The `desktop` module will install neovide/spotify/obsidian — they'll build and be present in the Nix store but are useless on a headless VM. Accept the disk cost or switch to `development` profile to skip them.
- Build time may be long if `nixpkgs-25.11-darwin` has poor Linux cache coverage. Monitor with `nix log`.

### Phase 4: System-Level Config (Manual, Outside Nix)

These are provided by the `mash` nixosConfiguration but can't be managed by home-manager. Set them up manually on Ubuntu:

```bash
# SSH server hardening (matching mash's services module)
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Firewall (matching mash's firewall config — only SSH open)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable

# Tailscale (matching mash's home-lab module)
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Set hostname
sudo hostnamectl set-hostname mash
```

## System-Wide Impact

- **Overlay evaluation**: The Darwin-only overlay fixes (Phase 1a) affect all homeConfigurations, not just this deployment. Ensure they don't break existing Darwin builds by using conditional logic rather than removing the overrides.
- **Swift module guard**: Affects Neovim config on all Linux home-manager activations. Currently only `mash` is Linux, so impact is contained.
- **Profile choice**: Using `full` profile means ~26 modules evaluate. Some modules (replicated, desktop) pull in niche packages that inflate closure size on a headless server.

## Acceptance Criteria

- [ ] `nix eval --impure .#homeConfigurations.crdant.activationPackage` succeeds on x86_64-linux (overlay fix)
- [ ] `home-manager switch --flake .#crdant --impure` completes without errors on the Ubuntu VM
- [ ] Zsh launches with oh-my-zsh custom theme
- [ ] Neovim starts without sourcekit.lua errors
- [ ] Git commits work with GPG signing
- [ ] SOPS secrets decrypt successfully (AI module MCP servers, etc.)
- [ ] SSH to homelab hosts works (if 1Password is configured on Linux)
- [ ] Tailscale is connected

## Dependencies & Risks

**Dependencies:**
- GPG private key must be transferable to the VM
- The dotfiles repo must be accessible from the VM (GitHub, or clone via SSH)
- VM needs internet access for Nix binary cache and package fetching

**Risks:**
- **Binary cache misses**: `nixpkgs-25.11-darwin` may not have Linux substitutes cached. Mitigation: monitor build times; consider adding a `nixpkgs-linux` input or switching to `release-25.11` branch.
- **Replicated overlay packages**: `kots`, `replicated`, `troubleshoot-sbctl` may have untested Linux build paths. Mitigation: if builds fail, temporarily override with `lib.optionals isLinux []` in the replicated module.
- **`mlx-lm` Python package**: This is Apple MLX (Metal) only and will fail on Linux. Must be guarded in the overlay.
- **VM resources**: Building from source requires adequate CPU/RAM. Recommend 4+ vCPUs, 8GB+ RAM.

## Sources & References

- `flake.nix` — system definitions and homeConfigurations
- `systems/hosts/mash/default.nix` — mash host config
- `systems/roles/jumpbox.nix` — jumpbox role (system-level modules)
- `overlays/default.nix:10-18` — Darwin-only `mas` and `container` overrides
- `home/modules/swift/default.nix:27-29` — unguarded sourcekit.lua
- `home/modules/homelab/default.nix` — macOS 1Password agent paths
- `home/modules/home-network/default.nix` — macOS 1Password agent paths
- `home/profiles/full.nix` — full profile module list
- [Determinate Nix Installer](https://install.determinate.systems/nix)
