---
date: 2025-10-18T15:43:27+0000
researcher: Claude Code
git_commit: 5c08c54ff6293d144cdf36128a18914dd8286cb1
branch: feature/crdant/provides-env-for-apps
repository: dotfiles
topic: "Making Terminal Environment Variables Available to Desktop Apps on Darwin"
tags: [research, codebase, darwin, macos, environment-variables, gui-apps, nix-darwin, home-manager]
status: complete
last_updated: 2025-10-18
last_updated_by: Claude Code
---

# Research: Making Terminal Environment Variables Available to Desktop Apps on Darwin

**Date**: 2025-10-18T15:43:27+0000
**Researcher**: Claude Code
**Git Commit**: 5c08c54ff6293d144cdf36128a18914dd8286cb1
**Branch**: feature/crdant/provides-env-for-apps
**Repository**: dotfiles

## Research Question

How can environment variables that are currently available in terminal environments be made available to Desktop/GUI applications on Darwin (macOS)?

## Summary

This codebase uses **nix-darwin** and **Home Manager** for declarative system configuration. Currently, environment variables are primarily configured for shell sessions via:
- `home.sessionVariables` (user-level, cross-shell)
- `home.sessionPath` (PATH modifications)
- `programs.zsh.envExtra` (shell-specific environment setup)

**Key Finding**: The codebase does **not** currently have a mechanism to propagate terminal environment variables to GUI/Desktop applications on macOS. The traditional macOS approach would use `launchd` or `~/.MacOSX/environment.plist`, but this codebase uses nix-darwin's declarative system management instead.

**Solution Path**: To make environment variables available to GUI apps, you should use **nix-darwin's `launchd.user.agents`** or configure system-level environment variables that are inherited by GUI applications at login.

## Detailed Findings

### Current Environment Variable Configuration

#### User-Level Session Variables
**File**: `home/modules/base/default.nix:14-19`

The primary mechanism for setting user environment variables:

```nix
home = {
  sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXPKGS_ALLOW_UNFREE = 1;
    NIXPKGS_ALLOW_BROKEN = 1;
  };
};
```

**Scope**: These variables are available in shell sessions (zsh, bash, fish) but **NOT** automatically available to GUI applications.

#### Shell-Specific Environment Variables
**File**: `home/modules/base/default.nix:278-288`

More complex environment setup using ZSH:

```nix
programs = {
  zsh = {
    envExtra = ''
      export XDG_CONFIG_HOME="${config.xdg.configHome}"

      if [[ -d $HOME/.rd ]] ; then
        export PATH=$PATH:"$HOME/.rd/bin"
      fi

      unset RPS1
    '';
  };
};
```

**Scope**: Only available in ZSH sessions, not to GUI applications.

#### Module-Specific Variables
Multiple modules define their own environment variables:
- `home/modules/infrastructure/default.nix:37-43` - GOVC_URL, GOVC_USERNAME, etc.
- `home/modules/ai/default.nix:67-74` - CLAUDE_CONFIG_DIR
- `home/modules/certificates/default.nix:40-42` - CERTBOT_ROOT
- `home/modules/kubernetes/default.nix` - K8s-related variables

**Scope**: Shell sessions only.

### System-Level Configuration

#### System Environment Variables
**File**: `systems/modules/base/terminfo.nix:67-69`

```nix
environment.variables = {
  TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo";
};
```

**Note**: `environment.variables` in nix-darwin sets system-wide environment variables, but the current usage is minimal and focused on terminal-specific settings.

#### Desktop Module
**File**: `systems/modules/desktop/default.nix:55-70`

The desktop module manages GUI applications via Homebrew:

```nix
environment = {
  systemPackages = with pkgs; [
    espanso
    slack
    zoom-us
    # ... more GUI apps
  ];
};
```

**Finding**: No environment variable configuration specific to GUI applications.

### No Traditional macOS Environment Mechanisms Found

**Traditional approaches NOT in use:**
1. **`~/.MacOSX/environment.plist`** - Not found or configured
2. **launchd agents for environment** - Not configured
3. **`/etc/launchd.conf`** - Deprecated on modern macOS, not used
4. **Login hooks** - Not configured

**Why**: This codebase uses nix-darwin's declarative approach, which avoids imperative configuration files.

## Architecture Insights

### Current Architecture
```
┌─────────────────────────────────────┐
│   Shell Sessions (zsh/bash/fish)   │
│                                     │
│  ✓ home.sessionVariables           │
│  ✓ home.sessionPath                │
│  ✓ programs.zsh.envExtra           │
│  ✓ Module-specific env vars        │
└─────────────────────────────────────┘
         ↑
         │ Available in shells
         │
┌─────────────────────────────────────┐
│      Terminal Applications          │
│  (nvim, git, kubectl, etc.)         │
└─────────────────────────────────────┘

         ✗ NOT available ✗

┌─────────────────────────────────────┐
│      GUI/Desktop Applications       │
│  (Slack, VS Code, Browsers, etc.)   │
└─────────────────────────────────────┘
```

### Nix-Darwin Configuration Flow
```
flake.nix (Entry point)
    ↓
darwinConfigurations.{host}
    ↓
systems/hosts/{host}/default.nix
    ↓
systems/modules/{various}/default.nix
    ↓
nix-darwin system configuration
    (system.defaults, environment, etc.)
```

### Home Manager Configuration Flow
```
flake.nix (Entry point)
    ↓
homeConfigurations.{user}@{host}
    ↓
home/users/{user}/{profile}.nix
    ↓
home/modules/{various}/default.nix
    ↓
home-manager user configuration
    (home.sessionVariables, programs.*, etc.)
```

## Recommended Solutions

### Option 1: System-Wide Environment Variables (Simplest)

For variables that should be available everywhere (shells + GUI apps), use nix-darwin's system-level environment configuration.

**File to modify**: Create or modify a system module (e.g., `systems/modules/environment/default.nix`)

```nix
{ config, pkgs, lib, ... }:

{
  # System-wide environment variables for GUI and shell apps
  environment.variables = {
    # Example: Make these available to all applications
    MY_VAR = "value";
    ANOTHER_VAR = "value2";
  };
}
```

**Scope**: Available to both shell sessions and GUI applications after logout/login.

### Option 2: launchd User Agents (More Control)

For more complex scenarios, use nix-darwin's `launchd.user.agents` to set environment variables at user login.

**File to create**: `systems/modules/environment/gui-environment.nix`

```nix
{ config, pkgs, lib, ... }:

{
  launchd.user.agents.environment = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          launchctl setenv MY_VAR "value"
          launchctl setenv PATH "$PATH:/custom/path"
        ''
      ];
      RunAtLoad = true;
    };
  };
}
```

**Scope**: Runs at user login, sets environment for all user processes including GUI apps.

### Option 3: Per-Application Environment (Most Specific)

For application-specific environment, use home-manager's `home.file` to create application-specific config files.

**Example for VS Code** (`home/modules/development/vscode.nix`):

```nix
{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "terminal.integrated.env.osx" = {
        MY_VAR = "value";
      };
    };
  };
}
```

### Option 4: Hybrid Approach (Recommended)

1. **Core variables** → `environment.variables` (system-level)
2. **Development tools** → Keep in shell configs for flexibility
3. **App-specific** → Use app-specific configuration

## Code References

### Key Configuration Files
- `home/modules/base/default.nix:14-19` - Current sessionVariables
- `home/modules/base/default.nix:21-30` - Current sessionPath
- `home/modules/base/default.nix:278-288` - ZSH envExtra
- `systems/modules/base/terminfo.nix:67-69` - System environment.variables example
- `systems/modules/desktop/default.nix:55-70` - Desktop applications
- `flake.nix:61-67` - darwinConfigurations

### Example Modules with Environment Variables
- `home/modules/infrastructure/default.nix:37-43` - Infrastructure tools
- `home/modules/ai/default.nix:67-74` - AI tools
- `home/modules/certificates/default.nix:40-42` - Certificate management
- `home/modules/kubernetes/default.nix:30-32` - Kubernetes tools

## Implementation Checklist

To make terminal environment variables available to GUI apps:

1. **Identify variables** - Determine which environment variables need to be available to GUI apps
2. **Choose approach** - Select Option 1, 2, 3, or 4 based on requirements
3. **Create module** - Create `systems/modules/environment/default.nix` or similar
4. **Configure variables** - Use `environment.variables` or `launchd.user.agents`
5. **Import module** - Add module import to system configuration
6. **Test** - Run `darwin-rebuild switch` and logout/login
7. **Verify** - Launch a GUI app and check if variables are available

## Open Questions

1. **Which specific environment variables need to be available to GUI apps?**
   - PATH modifications?
   - API keys or configuration paths?
   - Tool-specific variables?

2. **Should all terminal variables be available to GUI apps, or only a subset?**
   - Security consideration: Some variables might be sensitive
   - Performance consideration: Some variables might be shell-specific

3. **What's the precedence when combining system and user environment variables?**
   - nix-darwin's `environment.variables` vs home-manager's `home.sessionVariables`

4. **Are there any GUI applications that currently lack necessary environment variables?**
   - This would help prioritize which variables to expose

5. **Should this be per-profile or global?**
   - Consider if different profiles (minimal, development, ai, etc.) need different GUI environments

## Related Resources

- [nix-darwin documentation](https://github.com/LnL7/nix-darwin)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [macOS launchd documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

## Next Steps

1. **Discuss requirements** - Determine which variables need GUI access
2. **Design module structure** - Create a clean, modular solution
3. **Implement incrementally** - Start with critical variables
4. **Test thoroughly** - Verify GUI apps receive correct environment
5. **Document patterns** - Add examples to module documentation
