---
date: 2025-10-17T10:30:00-04:00
researcher: Claude Code
git_commit: e85d4693dbb8cf5e7313eeb5b367c60ffbfa9d8a
branch: feature/crdant/configures-dock
repository: crdant/dotfiles
topic: "Configuring macOS Dock with Activation Script using dockutil"
tags: [research, codebase, darwin, dock, activation-scripts, dockutil, nix-darwin]
status: complete
last_updated: 2025-10-17
last_updated_by: Claude Code
last_updated_note: "Added actual dock layout (23 apps) and dockutil installation requirements"
---

# Research: Configuring macOS Dock with Activation Script

**Date**: 2025-10-17T10:30:00-04:00
**Researcher**: Claude Code
**Git Commit**: e85d4693dbb8cf5e7313eeb5b367c60ffbfa9d8a
**Branch**: feature/crdant/configures-dock
**Repository**: crdant/dotfiles

## Research Question

What would it take to configure the macOS Dock with an activation script that follows the current dock layout on this machine? The solution needs to:
- Use the `dockutil` command (already available)
- Account for apps installed by Nix and pre-existing apps
- Only run on Darwin (macOS)
- Be placed in the appropriate directory structure

## Summary

After researching the codebase, the dock configuration should be in the **home-manager modules** (not system modules) since the Dock is a per-user environment setting. Key findings:

1. **CORRECT LOCATION**: Add to existing `home/modules/desktop/default.nix` - This is a user environment configuration, not a system configuration
2. **Pattern to use**: `home.activation` with `lib.hm.dag.entryAfter ["writeBoundary"]` for home-manager activation scripts
3. **Alternative explored**: System-level activation scripts exist in `systems/modules/hardening/` but are for system-wide configs (SSH, firewall, kernel)
4. **Current dock config**: Exists at `systems/modules/system-defaults/default.nix:52-64` but only has behavior settings, not app items
5. **No dockutil usage exists** currently in the codebase - this would be the first use
6. **Integration point**: Desktop module is already imported in `home/profiles/full.nix:5` - no additional imports needed

## Detailed Findings

### 1. Home-Manager Module Structure (RECOMMENDED APPROACH)

The codebase uses home-manager for per-user environment configuration:

**Home Module Location**: `home/modules/`

**Existing modules follow this pattern**:
```nix
{ pkgs, lib, config, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  home.packages = with pkgs; [ ... ];

  home.file = { ... };

  # For activation scripts:
  home.activation.scriptName = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Shell commands run as the user
    ${pkgs.dockutil}/bin/dockutil --remove all
    # ...
  '';
}
```

**Key differences from system activation**:
- Runs as the user (not root) - no need for `su`
- Uses `home.activation` instead of `system.activationScripts`
- Uses `lib.hm.dag.entryAfter` for dependency ordering
- Located in `home/modules/` not `systems/modules/`

**Integration**:
- Import in `home/profiles/full.nix:3-27` (add to imports list)
- OR import in `home/users/crdant/darwin.nix` for Darwin-only config

**Reference**: `home/modules/desktop/default.nix:1-76` shows the home module pattern

### 2. System Activation Scripts (For Reference Only)

System-level activation scripts are located in `systems/modules/hardening/` but are for system-wide configs, not user environments:

**Location**: `/systems/modules/hardening/`

| Script | File | Line | Purpose | Darwin-Only? |
|--------|------|------|---------|--------------|
| `ssh-host-keys` | `ssh.nix` | 157 | Generate SSH host keys | Yes (conditional) |
| `user-hardening` | `users.nix` | 137 | Secure home directory permissions | No |
| `firewall-setup` | `firewall.nix` | 157 | Enable macOS packet filter | Yes |
| `kernel-hardening` | `kernel.nix` | 173 | Apply sysctl kernel hardening | Yes |
| `audit-setup` | `audit.nix` | 326 | Create audit log directories | No |

**Note**: These are system configs (SSH keys, firewall, kernel). The Dock is a user config, so use home-manager instead.

### 2. Activation Script Pattern

All Darwin-specific activation scripts use this pattern:

```nix
{ inputs, pkgs, lib, options, config, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  system.activationScripts.script-name = lib.mkIf isDarwin {
    text = ''
      # Shell script content here
      ${pkgs.package}/bin/command

      # Conditional logic
      if [ condition ]; then
        echo "Doing something"
      fi
    '';
  };
}
```

**Best Darwin-Only Examples:**
- **`systems/modules/hardening/kernel.nix:173-220`** - Shows complete Darwin-only activation script
- **`systems/modules/hardening/firewall.nix:157-165`** - Simpler Darwin-only example

### 3. Darwin-Specific Configuration Patterns

The codebase uses multiple patterns for Darwin-specific code:

#### Pattern 1: Platform Detection Variable
```nix
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
```
**Usage**: 60+ files use this pattern

#### Pattern 2: Conditional Block with `lib.mkIf`
```nix
system.activationScripts.my-script = lib.mkIf isDarwin {
  text = ''
    # macOS-only commands
  '';
};
```
**Best Reference**: `systems/modules/hardening/kernel.nix:173`

#### Pattern 3: Attribute Capability Detection
```nix
supportsDarwinDefaults = builtins.hasAttr "defaults" options.system;
darwinConfig = lib.optionalAttrs supportsDarwinDefaults {
  # Darwin-specific configuration
};
```
**Best Reference**: `systems/modules/system-defaults/default.nix:8-9`

### 4. Existing Dock Configuration

**Location**: `systems/modules/system-defaults/default.nix:52-64`

Current dock settings (but NO app items configured):
```nix
dock = {
  # Enable spring loading for all Dock items
  enable-spring-load-actions-on-all-items = true;

  # Don't show Dashboard as a Space
  dashboard-in-overlay = true;

  # Don't automatically rearrange Spaces based on most recent use
  mru-spaces = false;

  # Don't show recent applications in Dock
  show-recents = false;
};
```

**Important**: This only configures dock *behavior*, not dock *items* (apps). A `dockutil` activation script would complement this by managing the actual apps in the dock.

### 5. Module Structure and Integration

**Home Module Organization** (Recommended for Dock):
```
home/
├── modules/
│   ├── base/
│   ├── desktop/          # Desktop apps, GUI configs ← ADD DOCK CONFIG HERE
│   ├── editor/
│   ├── development/
│   └── ... (25 modules total)
├── profiles/
│   ├── full.nix          # Imports all modules (including desktop)
│   ├── development.nix
│   └── minimal.nix
└── users/
    └── crdant/
        ├── darwin.nix    # Darwin-specific user config
        └── crdant.nix    # Cross-platform user config
```

**Recommended Location for Dock Activation**:
- **CORRECT**: Add to existing `home/modules/desktop/default.nix`
- **No additional imports needed**: Desktop module already imported in `home/profiles/full.nix:5`

**System Module Organization** (For reference - not for dock):
```
systems/
└── modules/
    ├── base/
    ├── desktop/          # System-level desktop packages (Homebrew)
    ├── hardening/        # System security configs
    └── system-defaults/  # macOS defaults (behavior only)
```

### 6. dockutil Command Usage

The `dockutil` command is available (mentioned in research question) but not currently used in the codebase (grep returned no matches).

**Typical dockutil commands**:
```bash
# Remove all items
dockutil --remove all

# Add an app
dockutil --add "/Applications/App.app"

# Add with position
dockutil --add "/Applications/App.app" --position 1

# Add folder
dockutil --add "~/Downloads" --view grid --display folder --sort dateadded

# Remove an app
dockutil --remove "App Name"
```

### 7. Handling Nix vs Pre-existing Apps

**Challenge**: Apps can come from multiple sources:
1. **Nix-installed apps**: Located in `/nix/store/.../Applications/`
2. **Homebrew casks**: Typically in `/Applications/`
3. **Mac App Store apps**: In `/Applications/`
4. **Manually installed apps**: In `/Applications/` or `~/Applications/`

**Strategy for Home-Manager Activation Script** (RECOMMENDED):
```nix
home.activation.configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # No need for su - this runs as the user

  # Clear the dock
  ${pkgs.dockutil}/bin/dockutil --remove all --no-restart

  # Add Nix-installed apps (these paths change with each rebuild)
  # Use ${pkgs.package} to get the current nix store path
  if [ -d "${pkgs.firefox}/Applications/Firefox.app" ]; then
    ${pkgs.dockutil}/bin/dockutil --add "${pkgs.firefox}/Applications/Firefox.app" --no-restart
  fi

  # Add system/homebrew apps (stable paths in /Applications)
  if [ -d "/Applications/Safari.app" ]; then
    ${pkgs.dockutil}/bin/dockutil --add "/Applications/Safari.app" --no-restart
  fi

  # Restart the dock to apply changes
  killall Dock
'';
```

**Alternative: System Activation Script** (Not recommended for user configs):
```nix
system.activationScripts.configure-dock = lib.mkIf isDarwin {
  text = ''
    CURRENT_USER=$(stat -f '%Su' /dev/console)
    run_as_user() { su - "$CURRENT_USER" -c "$1"; }
    run_as_user "${pkgs.dockutil}/bin/dockutil --remove all"
    # ... (requires su, more complex)
  '';
};
```

## Code References

**Home-Manager (RECOMMENDED for Dock)**:
- `home/modules/desktop/default.nix:1-76` - Example home module structure
- `home/profiles/full.nix:3-27` - Profile that imports all modules
- `home/users/crdant/darwin.nix:1-58` - Darwin-specific user configuration

**System Configuration (For reference only)**:
- `systems/modules/hardening/kernel.nix:173-220` - System activation script example (NOT for dock)
- `systems/modules/hardening/firewall.nix:157-165` - System activation script example (NOT for dock)
- `systems/modules/system-defaults/default.nix:52-64` - Existing dock behavior configuration
- `systems/modules/system-defaults/default.nix:8-9` - Platform detection pattern

## Architecture Insights

1. **Separation of Concerns**:
   - System configs (`systems/modules/`) for system-wide settings (SSH, firewall, kernel)
   - User configs (`home/modules/`) for per-user environment (shell, editor, dock, desktop apps)
   - The Dock is a **user configuration**, so it belongs in `home/modules/`

2. **Home-Manager Activation**:
   - `home.activation` scripts run as the user (no need for `su`)
   - Use `lib.hm.dag.entryAfter ["writeBoundary"]` for ordering
   - Timing: Runs during `home-manager switch` or `darwin-rebuild switch` (home-manager integrated)

3. **System Activation** (for reference):
   - `system.activationScripts` run as root during `darwin-rebuild switch`
   - Requires `su` for user-specific commands
   - Used for system-wide configs only

4. **Modularity**: Both system and home use a highly modular structure with individual modules for each feature

5. **Conditional Configuration**: Extensive use of `lib.mkIf`, `lib.optionals`, and `builtins.hasAttr` ensures cross-platform compatibility

6. **Nix Store Paths**: Nix-installed apps have store paths like `/nix/store/hash-package-version/Applications/App.app`, which change with each rebuild. Using `${pkgs.package}` in the activation script ensures the correct path is used.

## Implementation Plan

To implement dock configuration with dockutil using the existing desktop module:

### Step 1: Add dockutil Package and Activation Script to Desktop Module

Edit `home/modules/desktop/default.nix`:

**A. Add dockutil to packages** (around line 10-19):
```nix
home = {
  # Basic packages for all environments
  packages = with pkgs; [
    _1password-gui
    _1password-cli
    neovide
  ] ++ lib.optionals isDarwin [
    dockutil    # Add this line
    vimr
    (callPackage ./vimr-wrapper.nix { inherit config; })
  ] ++ lib.optionals isLinux [
    obsidian
  ];
```

**B. Add dock activation after the `xdg` block** (after line 74):
```nix
{ inputs, outputs, config, pkgs, lib, username, homeDirectory, secretsFile ? null, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # ... existing configuration (home.packages, home.file, programs, xdg) ...

  xdg = {
    enable = true;
    configFile = {
    } // lib.optionalAttrs isDarwin {
      "karabiner/karabiner.json" = {
        text = builtins.readFile ./config/karabiner/karabiner.json;
      };
      "ghostty/config" = {
        source = ./config/ghostty/config;
      };
    };
  };

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
}
```

### Step 2: Apply Configuration
```bash
# Using darwin with integrated home-manager:
darwin-rebuild switch --flake .
```

### Step 3: Verify Dock Configuration
After the rebuild completes, your dock should be configured with all 23 applications in the specified order.

**Note**:
- The desktop module is already imported in `home/profiles/full.nix:5`, so no additional imports are needed
- Current dock layout has been captured and documented (see Update 3 above)
- All apps use stable paths, no Nix store paths needed

## Alternative Approaches

### Option 1: Declarative Dock Items (More Complex)
Instead of shell commands, define dock items declaratively:
```nix
options.systems.dock.items = lib.mkOption {
  type = lib.types.listOf lib.types.str;
  default = [];
  description = "List of application paths to add to dock";
};
```

Then generate the activation script from this list.

### Option 2: Extend system-defaults Module
Add dock items configuration directly to `systems/modules/system-defaults/default.nix` alongside existing dock settings.

### Option 3: User-Level Configuration
Use Home Manager instead of system activation scripts:
```nix
# In home/users/crdant/darwin.nix
home.activation.configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
  ${pkgs.dockutil}/bin/dockutil --remove all
  ${pkgs.dockutil}/bin/dockutil --add "/Applications/Safari.app"
  # ...
'';
```

**Trade-offs**:
- System activation: Runs as root, needs `su` for user context
- Home Manager: Runs as user, simpler but separates system/user config

## Open Questions

1. **Should dock configuration be system-wide or per-user?**
   - **RESOLVED**: Per-user with home-manager (user correctly identified this)
   - System activation would require `su` and is inappropriate for user configs

2. **How to handle dynamic Nix store paths elegantly?**
   - Current approach: Use `${pkgs.package}` interpolation
   - Alternative: Symlink apps to stable paths
   - **Recommendation**: Use `${pkgs.package}` for Nix apps, check `/Applications/` for others

3. **Should this be declarative or imperative?**
   - Current approach: Imperative with `home.activation` script
   - Alternative: Declarative list of dock items that generates the script
   - **Recommendation**: Start with imperative, consider declarative if useful

4. **How to preserve manual dock customizations?**
   - Current approach: Replaces entire dock on activation
   - Alternative: Only add/remove specific items, preserve user-added items
   - **Recommendation**: Full replacement for reproducibility

## Recommendations

1. **Use existing desktop module**: Add dock activation to `home/modules/desktop/default.nix`, NOT a new module or system module
   - The Dock is a per-user configuration, belongs with desktop configs
   - Home-manager activation runs as the user (simpler, no `su` needed)
   - Desktop module is already imported, no additional imports needed

2. **Activation pattern**: Use `home.activation.configureDock = lib.hm.dag.entryAfter ["writeBoundary"]`

3. **Darwin-only**: Wrap activation in `lib.mkIf isDarwin` to prevent errors on Linux

4. **Handle both sources**: Check for apps in both Nix store (`${pkgs.app}`) and `/Applications/`

5. **Document expected behavior**: Clearly state that activation replaces the entire dock

6. **Test incrementally**: Start with a few apps, verify it works, then add more

## Next Steps

1. ~~Capture current dock layout with `dockutil --list`~~ ✓ COMPLETED
2. Edit `home/modules/desktop/default.nix`:
   - Add `dockutil` to `home.packages` (line ~15)
   - Add `home.activation.configureDock` block after `xdg` section (line ~74)
3. Test with `darwin-rebuild switch --flake .`
4. Verify all 23 apps appear in dock in correct order

## Follow-up Research 2025-10-17

### Update 1: User Context
User correctly identified that the Dock is a per-user environment configuration, not a system configuration. Updated all recommendations to use home-manager modules with `home.activation` instead of `systems/modules/` with `system.activationScripts`.

**Key correction**: Home-manager activation scripts run as the user (no need for `su`), making them simpler and more appropriate for user-specific configurations like the Dock.

### Update 2: Use Existing Module
User requested using the existing `home/modules/desktop/default.nix` instead of creating a new dock module. Updated implementation plan to add dock activation directly to the desktop module (after line 74).

**Rationale**:
- Desktop module already handles GUI applications and desktop configurations
- No additional imports needed (desktop already in `home/profiles/full.nix:5`)
- Keeps related functionality together

### Update 3: Current Dock Configuration Discovered

Ran `dockutil --list` to capture the actual dock layout:

**Current dock contains 23 applications:**

Third-party apps (in `/Applications/`):
1. Ghostty
2. Arc
3. Slack
4. Superhuman
5. zoom.us
6. Twitter
7. Todoist
8. Bear
9. Keynote
10. Numbers
11. Pages

System apps (in `/System/Applications/`):
1. Messages
2. Contacts
3. News
4. Music
5. TV
6. Books
7. Photos
8. App Store
9. Activity Monitor (`/System/Applications/Utilities/Activity Monitor.app`)
10. Console (`/System/Applications/Utilities/Console.app`)
11. System Settings

**Key findings:**
- All apps have stable paths (no Nix-installed apps in current dock)
- No need for `${pkgs.package}` interpolation for current setup
- System apps use `/System/Applications/` prefix
- Third-party apps use `/Applications/` prefix
- Some app names contain spaces (e.g., "Activity Monitor.app", "System Settings.app")

**dockutil Installation Status:**
- Currently at: `/usr/local/bin/dockutil` (v3.0.2)
- NOT managed by Homebrew or Nix
- Available in nixpkgs: `legacyPackages.aarch64-darwin.dockutil` (v3.1.3)
- **ACTION REQUIRED**: Add `dockutil` to `home.packages` in desktop module to manage via Nix
