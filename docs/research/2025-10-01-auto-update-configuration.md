---
date: 2025-10-02T01:11:49+0000
researcher: Claude
git_commit: 9a40fa1befa345f70544bbcccab27e631633a99a
branch: feature/crdant/installs-codelayer
repository: crdant/dotfiles
topic: "Is my configuration auto updating?"
tags: [research, codebase, auto-update, nix, homebrew, system-defaults]
status: complete
last_updated: 2025-10-01
last_updated_by: Claude
---

# Research: Is my configuration auto updating?

**Date**: 2025-10-02T01:11:49+0000
**Researcher**: Claude
**Git Commit**: 9a40fa1befa345f70544bbcccab27e631633a99a
**Branch**: feature/crdant/installs-codelayer
**Repository**: crdant/dotfiles

## Research Question
Is my configuration auto updating?

## Summary

**Yes, but partially.** Your configuration has several automatic update mechanisms:

✅ **Auto-updating:**
- Nix system packages (daily at 02:00 with 45min random delay)
- macOS system updates (daily checks, automatic installation)
- Homebrew packages (on nix-darwin activation)
- App Store apps (automatic)
- SSL certificates (Wednesdays at 15:48)

❌ **NOT auto-updating:**
- Git repository sync (manual `git pull` required)
- Home Manager user environment (manual `make switch` required)
- Nix flake inputs (manual `make update` required)

## Detailed Findings

### Nix System Auto-Upgrade

**File**: `systems/modules/system-defaults/default.nix:178-193`

Your dotfiles configure automatic system upgrades via nix-darwin:

```nix
supportsAutoUpgrade = builtins.hasAttr "autoUpgrade" options;
autoUpgradeConfig = lib.optionalAttrs supportsAutoUpgrade {
  autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
};
```

**Schedule**: Daily at 02:00 (2:00 AM) with 45-minute randomized delay
**Behavior**:
- Updates nixpkgs flake input automatically
- Rebuilds system configuration
- Allows automatic reboots if needed
- Prints build logs

### macOS System Updates

**File**: `systems/modules/system-defaults/default.nix:49-50, 89-97, 109-112`

macOS automatic updates are fully enabled:

```nix
SoftwareUpdate = {
  AutomaticallyInstallMacOSUpdates = true;
};

"com.apple.SoftwareUpdate" = {
  AutomaticCheckEnabled = true;
  ScheduleFrequency = 1;  # Check daily
  AutomaticDownload = 1;
  CriticalUpdateInstall = 1;
};

"com.apple.commerce" = {
  AutoUpdate = true;
  AutoUpdateRestartRequired = true;
};
```

**Behavior**:
- Checks for updates daily
- Downloads updates automatically
- Installs critical security updates automatically
- Auto-updates App Store apps
- Can restart if required

### Homebrew Auto-Update

**File**: `systems/modules/desktop/default.nix:11-15`

Homebrew packages update on system activation:

```nix
homebrew = {
  enable = true;
  onActivation = {
    autoUpdate = true;
    upgrade = true;
  };
};
```

**Schedule**: On every `darwin-rebuild switch` or system activation
**Behavior**: Updates Homebrew and upgrades all installed packages

### Scheduled Jobs

#### SSL Certificate Renewal

**File**: `home/modules/certificates/default.nix`

**Agent**: `io.crdant.certbotRenewal`
**Schedule**: Wednesdays at 15:48 (3:48 PM)
**Command**: `certbot renew`
**Logs**:
- Output: `${config.xdg.stateHome}/certbot/renewal.out`
- Errors: `${config.xdg.stateHome}/certbot/renewal.err`

### What is NOT Auto-Updating

#### Git Repository Sync

**Status**: ❌ No automatic sync configured

The dotfiles repository itself does not automatically pull updates from the remote. You must manually:
- Run `git pull` to fetch changes
- Or use `make update` to update flake inputs (doesn't pull git changes)

**No evidence of**:
- Git hooks for auto-pull
- LaunchAgents/LaunchDaemons for periodic sync
- Activation scripts that pull from remote

#### Home Manager

**File**: `home/modules/base/default.nix:102`

```nix
programs.home-manager.enable = true;
```

**Status**: ❌ No automatic updates configured

Home Manager requires manual activation via:
- `make switch` or `make user`
- `home-manager switch --flake .#<user>`

The system auto-upgrade handles system-level packages, but user environment updates require manual intervention.

#### Nix Flake Inputs

While the system auto-upgrade updates the `nixpkgs` input, other flake inputs require manual updating via:
- `make update` (runs `nix flake update`)

## Code References

- `systems/modules/system-defaults/default.nix:178-193` - Nix system auto-upgrade configuration
- `systems/modules/system-defaults/default.nix:49-50` - macOS update settings
- `systems/modules/system-defaults/default.nix:89-97` - Software Update preferences
- `systems/modules/system-defaults/default.nix:109-112` - App Store auto-update
- `systems/modules/desktop/default.nix:11-15` - Homebrew auto-update
- `home/modules/certificates/default.nix` - Certbot certificate renewal
- `home/modules/base/default.nix:102` - Home Manager configuration (no auto-update)
- `Makefile:33-35` - Manual flake update command

## Architecture Insights

Your dotfiles use a **layered update strategy**:

1. **System layer** (automatic): nix-darwin handles OS-level packages via daily auto-upgrade
2. **macOS layer** (automatic): Native macOS handles system updates and App Store apps
3. **Package layer** (semi-automatic): Homebrew updates on system activation
4. **User layer** (manual): Home Manager requires explicit activation
5. **Source layer** (manual): Git repository must be manually synced

This design separates system stability (automatic) from user environment customization (manual control), preventing unexpected changes to your user configuration while keeping the system secure and up-to-date.

### Missing Auto-Update Features

**Not configured**:
- Nix garbage collection (`nix.gc.automatic`)
- Nix store optimization (`nix.optimise.automatic`)
- Automatic Home Manager updates
- Periodic flake input updates (beyond nixpkgs)

## Related Research

No previous research documents found on this topic.

## Open Questions

1. Should Home Manager updates be automated or remain manual for stability?
2. Should the dotfiles repository auto-pull changes, or would this risk unexpected configuration changes?
3. Would periodic flake input updates (beyond nixpkgs) be beneficial or disruptive?
4. Should Nix garbage collection be automated to manage disk space?
