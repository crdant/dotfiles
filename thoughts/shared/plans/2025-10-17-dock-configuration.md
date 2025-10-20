# Dock Configuration with dockutil Implementation Plan

## Overview

Implement declarative Dock configuration using dockutil in home-manager, ensuring all 23 applications are configured in the correct order on every system rebuild. This replaces manual dock management with reproducible configuration managed through Nix.

## Current State Analysis

**What exists now:**
- Dock behavior settings in `systems/modules/system-defaults/default.nix:52-64` (show-recents: false, mru-spaces: false, etc.)
- Manual dock management (23 apps currently configured)
- dockutil v3.0.2 installed at `/usr/local/bin/dockutil` (NOT managed by Nix)
- Desktop module at `home/modules/desktop/default.nix:1-76` with Darwin-specific configs

**What's missing:**
- dockutil package in Nix configuration
- Activation script to configure dock items
- All 23 applications configured declaratively

**Key Constraints:**
- Must only run on Darwin (macOS)
- Must run as user (home-manager activation, not system activation)
- All apps have stable paths (no Nix store paths needed)
- Some app names contain spaces (e.g., "Activity Monitor.app", "System Settings.app")

## Desired End State

After implementation:
1. dockutil v3.1.3 is installed and managed via Nix in `home.packages`
2. Dock is automatically configured with all 23 apps in the correct order on every `darwin-rebuild switch`
3. Missing apps are silently skipped (no errors thrown)
4. Configuration is declarative and reproducible

**Verification:**
- Run `which dockutil` → should show Nix store path
- Run `dockutil --version` → should show v3.1.3
- Run `darwin-rebuild switch --flake .` → dock should be reconfigured
- Run `dockutil --list` → should show all 23 apps in correct order

## Key Discoveries

From research document `thoughts/shared/research/2025-10-17-dock-activation-script.md`:
- Desktop module already has Darwin-specific configs using `lib.optionalAttrs isDarwin` pattern (`home/modules/desktop/default.nix:22-36`)
- Home-manager activation scripts run as user, use `lib.hm.dag.entryAfter ["writeBoundary"]` for ordering
- Current dock: 11 third-party apps, 11 system apps, 1 app in Utilities
- dockutil available in nixpkgs at v3.1.3: `legacyPackages.aarch64-darwin.dockutil`

## What We're NOT Doing

- NOT creating a separate dock module (using existing desktop module)
- NOT using system activation scripts (using home-manager activation)
- NOT making dock configuration optional/toggleable (always runs on Darwin)
- NOT preserving manual dock customizations (full replacement on every rebuild)
- NOT handling Nix-installed apps with dynamic store paths (none in current dock)
- NOT implementing declarative dock items list (using imperative script)
- NOT adding error handling for missing apps (silent skip as requested)

## Implementation Approach

Two-phase implementation:
1. **Phase 1**: Add dockutil to home.packages for Nix management
2. **Phase 2**: Add home.activation script to configure dock items

Both changes go in the same file (`home/modules/desktop/default.nix`) and can be applied in a single commit. The phases are logical separations for clarity, not separate deployments.

**Strategy:**
- Use `lib.optionals isDarwin` for package inclusion (existing pattern in module)
- Use `lib.mkIf isDarwin` for activation script (ensures Darwin-only execution)
- Use `--no-restart` flag for all dockutil commands except the final `killall Dock`
- No existence checks for apps (dockutil handles missing apps gracefully)

## Phase 1: Add dockutil Package

### Overview
Add dockutil to the Darwin-specific packages list in the desktop module, ensuring it's managed by Nix.

### Changes Required

#### 1. Desktop Module - Package List
**File**: `home/modules/desktop/default.nix`
**Location**: Lines 14-16 (within the `lib.optionals isDarwin` block)
**Changes**: Add `dockutil` to the Darwin-specific package list

```nix
] ++ lib.optionals isDarwin [
  dockutil    # Add this line
  vimr
  (callPackage ./vimr-wrapper.nix { inherit config; })
```

**Complete context (lines 10-19):**
```nix
home = {
  # Basic packages for all environments
  packages = with pkgs; [
    _1password-gui
    _1password-cli
    neovide
  ] ++ lib.optionals isDarwin [
    dockutil    # NEW: Dock configuration tool
    vimr
    (callPackage ./vimr-wrapper.nix { inherit config; })
  ] ++ lib.optionals isLinux [
    obsidian
  ];
```

### Success Criteria

#### Automated Verification:
- [ ] Configuration builds successfully: `darwin-rebuild build --flake .`
- [ ] No Nix evaluation errors
- [ ] dockutil is in Nix profile after rebuild: `nix profile list | grep dockutil`

#### Manual Verification:
- [ ] `which dockutil` returns a path in `/nix/store/`
- [ ] `dockutil --version` shows version 3.1.3 (or later)
- [ ] Old dockutil at `/usr/local/bin/dockutil` can be removed manually if desired

---

## Phase 2: Add Dock Activation Script

### Overview
Add home-manager activation script that configures the dock with all 23 applications in the correct order. Runs on every rebuild, silently skips missing apps.

### Changes Required

#### 1. Desktop Module - Activation Script
**File**: `home/modules/desktop/default.nix`
**Location**: After the `xdg` block (after line 74)
**Changes**: Add complete `home.activation` block with dock configuration

```nix
# Dock configuration for Darwin
home.activation = lib.mkIf isDarwin {
  configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Configuring Dock..."

    # Clear existing dock items
    ${pkgs.dockutil}/bin/dockutil --remove all --no-restart

    # Third-party applications (in /Applications/)
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Ghostty.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Arc.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Slack.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Superhuman.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/zoom.us.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Twitter.app" --no-restart

    # System applications
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Messages.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Contacts.app" --no-restart

    # Productivity apps
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Todoist.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Bear.app" --no-restart

    # Media apps
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/News.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Music.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/TV.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Books.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Photos.app" --no-restart

    # iWork suite
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Keynote.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Numbers.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Pages.app" --no-restart

    # System utilities
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/App Store.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Utilities/Console.app" --no-restart
    ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/System Settings.app" --no-restart

    # Restart Dock to apply changes
    killall Dock

    echo "Dock configuration complete"
  '';
};
```

**Integration point:** This block should be added after the closing brace of the `xdg` configuration block (line 74) and before the final closing brace of the module.

**Full structure context:**
```nix
{ inputs, outputs, config, pkgs, lib, username, homeDirectory, secretsFile ? null, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # home.packages (with dockutil added - Phase 1)
  home = { ... };

  # nixpkgs config
  nixpkgs = { ... };

  # programs config
  programs = { ... };

  # xdg config
  xdg = {
    enable = true;
    configFile = { ... };
  }; # Line 74 - xdg block ends here

  # NEW: Dock configuration activation script
  home.activation = lib.mkIf isDarwin {
    configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # ... (activation script from above)
    '';
  };
} # Final closing brace
```

### Success Criteria

#### Automated Verification:
- [ ] Configuration builds successfully: `darwin-rebuild build --flake .`
- [ ] Home-manager activation completes without errors: `darwin-rebuild switch --flake .`
- [ ] Activation script runs (check output for "Configuring Dock..." message)
- [ ] No syntax errors in Nix expression

#### Manual Verification:
- [ ] All 23 apps appear in dock in correct order after rebuild
- [ ] Dock reloads automatically (via `killall Dock`)
- [ ] Missing apps (if any) are silently skipped without errors
- [ ] Verify specific order with: `dockutil --list`
- [ ] Dock persists across system reboots
- [ ] Running rebuild again produces idempotent results (same dock state)

---

## Testing Strategy

### Pre-Implementation:
1. Capture current dock state: `dockutil --list > /tmp/dock-before.txt`
2. Create backup of desktop module: `cp home/modules/desktop/default.nix home/modules/desktop/default.nix.backup`

### Phase 1 Testing:
1. Apply Phase 1 changes only
2. Run: `darwin-rebuild switch --flake .`
3. Verify dockutil is now Nix-managed: `which dockutil`
4. Check version: `dockutil --version`

### Phase 2 Testing:
1. Apply Phase 2 changes
2. Run: `darwin-rebuild switch --flake .`
3. Watch for "Configuring Dock..." message in output
4. Dock should reload automatically
5. Verify all apps present: `dockutil --list`
6. Compare to baseline: `diff /tmp/dock-before.txt <(dockutil --list)`

### Edge Cases to Test:
1. **Missing app**: Temporarily rename an app (e.g., `mv /Applications/Todoist.app /Applications/Todoist.app.bak`)
   - Expected: Script continues, app is skipped, other apps still added
   - Cleanup: Restore the app
2. **Idempotency**: Run `darwin-rebuild switch` twice
   - Expected: Dock state identical after both runs
3. **Dock crashes during config**: Kill Dock process during rebuild
   - Expected: Dock restarts and config completes

### Rollback Plan:
If implementation fails:
1. Restore backup: `cp home/modules/desktop/default.nix.backup home/modules/desktop/default.nix`
2. Run: `darwin-rebuild switch --flake .`
3. Manually restore dock: Use `/tmp/dock-before.txt` as reference

## Performance Considerations

- **Rebuild time**: Adding ~23 dockutil commands adds approximately 2-3 seconds to rebuild time (acceptable)
- **Dock restart**: The `killall Dock` command causes a brief visual flicker but is necessary for changes to apply
- **--no-restart flag**: Using this flag for all adds except the final one minimizes the number of dock restarts to just one

## Migration Notes

**For existing dockutil installation:**
- Old dockutil at `/usr/local/bin/dockutil` (v3.0.2) will remain until manually removed
- Nix-managed dockutil (v3.1.3) will take precedence in PATH
- No automatic cleanup needed - both can coexist safely
- Optional cleanup: `rm /usr/local/bin/dockutil` after verifying Nix version works

**For existing dock configuration:**
- Current manual dock setup will be replaced on first rebuild after implementation
- No data loss - just dock item positions change
- Recommendation: Capture current state before implementing (see Testing Strategy)

## References

- Research document: `thoughts/shared/research/2025-10-17-dock-activation-script.md`
- Desktop module: `home/modules/desktop/default.nix:1-76`
- System defaults (dock behavior): `systems/modules/system-defaults/default.nix:52-64`
- Home-manager activation pattern: `home/modules/desktop/default.nix:22-36` (existing Darwin-specific configs)
- dockutil nixpkgs: `legacyPackages.aarch64-darwin.dockutil` (v3.1.3)
