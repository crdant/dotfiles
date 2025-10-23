# GUI Environment Variables via launchd Agents Implementation Plan

## Overview

Enable GUI/Desktop applications on macOS to access environment variables that are currently only available in terminal sessions. This will be implemented using Home Manager's `launchd.agents` configuration with per-module launchd agents that use `launchctl setenv` to propagate variables to the GUI session.

## Current State Analysis

### What Exists Now

**Environment Variables (Shell Only):**
- `home.sessionVariables` in `home/modules/base/default.nix:14-19` defines EDITOR, VISUAL, NIXPKGS_* variables
- `home.sessionPath` in `home/modules/base/default.nix:21-30` adds custom paths (~/workspace/go/bin, Homebrew, etc.)
- `programs.zsh.envExtra` in `home/modules/base/default.nix:278-288` sets XDG_CONFIG_HOME
- Module-specific variables in ai, kubernetes, certificates, infrastructure modules

**Current Architecture:**
```
Terminal Sessions (zsh/bash/fish)
    ↓
    ✓ Has all environment variables
    ↓
Terminal Applications (nvim, kubectl, etc.)
    ↓
    ✓ Inherits from shell

GUI Applications (Claude Desktop, VS Code, etc.)
    ↓
    ✗ NO environment variables from shell config
```

### What's Missing

GUI applications launched from Finder, Spotlight, or Dock do NOT have access to:
- Custom PATH entries (~/workspace/go/bin, ~/.krew/bin, ~/.local/bin)
- EDITOR/VISUAL variables (needed by Git GUI clients)
- XDG_CONFIG_HOME (needed by XDG-compliant apps)
- CLAUDE_CONFIG_DIR (needed by Claude Desktop app)

### Key Discoveries

1. **Home Manager supports launchd agents**: `home/modules/certificates/default.nix:46-78` shows existing pattern for creating launchd agents
2. **Darwin-specific conditionals**: Modules use `isDarwin` to conditionally enable macOS-specific features
3. **No existing GUI environment setup**: No modules currently use launchd for environment variable propagation

## Desired End State

### Target Architecture

```
User Login
    ↓
launchd user agents (RunAtLoad=true)
    ↓
    launchctl setenv VAR "value"
    ↓
GUI Session Environment
    ↓
GUI Applications
    ✓ PATH includes ~/.local/bin, ~/workspace/go/bin, ~/.krew/bin, Homebrew paths
    ✓ EDITOR=nvim, VISUAL=nvim
    ✓ XDG_CONFIG_HOME set correctly
    ✓ CLAUDE_CONFIG_DIR set based on username
```

### Verification Methods

After implementation, GUI apps should have access to environment variables. Verify by:

#### Automated Verification:
- [ ] Home Manager builds successfully: `home-manager switch`
- [ ] Launchd agents are created: `launchctl list | grep io.crdant.env`
- [ ] No syntax errors in Nix configuration: `nix-instantiate --eval`

#### Manual Verification:
1. **Logout and log back in** (or reboot)
2. **Verify launchd agents loaded:**
   ```bash
   launchctl list | grep io.crdant.env
   # Should show: io.crdant.env.base, io.crdant.env.ai, io.crdant.env.kubernetes
   ```
3. **Check environment in GUI context:**
   ```bash
   launchctl getenv PATH
   launchctl getenv EDITOR
   launchctl getenv CLAUDE_CONFIG_DIR
   launchctl getenv XDG_CONFIG_HOME
   ```
4. **Test with actual GUI app:**
   - Open Claude Desktop → Check it finds config at CLAUDE_CONFIG_DIR
   - Open VS Code → Terminal should have correct PATH
   - Any app that spawns git → Should use nvim as EDITOR

## What We're NOT Doing

1. **Not exposing ALL environment variables** - Only PATH, EDITOR, VISUAL, XDG_CONFIG_HOME, CLAUDE_CONFIG_DIR
2. **Not using system-level configuration** - Using Home Manager (user-level) instead of nix-darwin system-level
3. **Not exposing sensitive variables** - GOVC_PASSWORD, API keys stay shell-only
4. **Not exposing Nix-specific variables** - NIXPKGS_ALLOW_UNFREE stays in shell sessions
5. **Not creating one monolithic agent** - Each module manages its own launchd agent
6. **Not modifying shell configuration** - Existing sessionVariables/sessionPath remain unchanged

## Implementation Approach

### Strategy

Use **per-module launchd agents** where each module that needs GUI environment variables creates its own launchd agent. This approach:
- Keeps environment configuration co-located with the module that needs it
- Allows modules to be independently enabled/disabled
- Follows the existing pattern in the certificates module
- Makes it easy to add more modules in the future

### Pattern

Each module will add a `launchd.agents` block (Darwin-only) that:
1. Runs at user login (`RunAtLoad = true`)
2. Uses a bash script with `launchctl setenv` to set variables
3. Has a unique label per module (e.g., `io.crdant.env.base`)
4. Logs to XDG-compliant paths for debugging

## Phase 1: Add launchd Agent to base Module

### Overview
Add GUI environment support to the base module for core variables that all GUI apps need.

### Changes Required

#### File: `home/modules/base/default.nix`

**Location:** After the `home.activation` block (around line 87), add a new `launchd` block.

**Add this new configuration block:**

```nix
launchd = lib.mkIf isDarwin {
  enable = true;
  agents = {
    "io.crdant.env.base" = {
      enable = true;
      config = {
        Label = "io.crdant.env.base";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            # Set PATH for GUI applications
            launchctl setenv PATH "${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/workspace/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

            # Set editor variables for Git GUI clients and other apps
            launchctl setenv EDITOR "nvim"
            launchctl setenv VISUAL "nvim"

            # Set XDG_CONFIG_HOME for XDG-compliant applications
            launchctl setenv XDG_CONFIG_HOME "${config.xdg.configHome}"
          ''
        ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.stateHome}/launchd/env.base.out";
        StandardErrorPath = "${config.xdg.stateHome}/launchd/env.base.err";
      };
    };
  };
};
```

**Important Notes:**
1. The PATH construction must include system paths (/usr/bin, etc.) in addition to custom paths
2. Uses `config.xdg.configHome` to reference the XDG config directory
3. Uses `config.home.homeDirectory` to reference the home directory
4. Logs go to `${config.xdg.stateHome}/launchd/` for debugging

### Success Criteria

#### Automated Verification:
- [ ] Nix configuration builds: `nix-instantiate --eval --strict home/modules/base/default.nix`
- [ ] Home Manager builds: `home-manager build`
- [ ] No Home Manager activation errors: Check output of `home-manager switch`

#### Manual Verification:
- [ ] After logout/login, launchd agent is loaded: `launchctl list | grep io.crdant.env.base`
- [ ] PATH is set in GUI context: `launchctl getenv PATH` includes ~/.local/bin, ~/workspace/go/bin, Homebrew paths
- [ ] EDITOR is set: `launchctl getenv EDITOR` returns "nvim"
- [ ] VISUAL is set: `launchctl getenv VISUAL` returns "nvim"
- [ ] XDG_CONFIG_HOME is set: `launchctl getenv XDG_CONFIG_HOME` returns correct path
- [ ] VS Code integrated terminal has correct PATH when opened via Finder/Spotlight
- [ ] Git operations from GUI apps use nvim as editor

---

## Phase 2: Add launchd Agent to ai Module

### Overview
Add GUI environment support to the ai module so Claude Desktop and other AI GUI tools can find their configuration.

### Changes Required

#### File: `home/modules/ai/default.nix`

**Location:** After the `programs.zsh` block (around line 76), add a new `launchd` block.

**Add this new configuration block:**

```nix
launchd = lib.mkIf isDarwin {
  enable = true;
  agents = {
    "io.crdant.env.ai" = {
      enable = true;
      config = {
        Label = "io.crdant.env.ai";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            # Set CLAUDE_CONFIG_DIR based on username (matches shell logic)
            if [[ "$(whoami)" == "chuck" ]] ; then
              launchctl setenv CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude/replicated"
            else
              launchctl setenv CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude/personal"
            fi
          ''
        ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.stateHome}/launchd/env.ai.out";
        StandardErrorPath = "${config.xdg.stateHome}/launchd/env.ai.err";
      };
    };
  };
};
```

**Important Notes:**
1. This replicates the same conditional logic from `programs.zsh.envExtra` (lines 67-74)
2. The username check ensures correct config directory for work (chuck) vs personal (crdant) contexts

### Success Criteria

#### Automated Verification:
- [ ] Nix configuration builds: `nix-instantiate --eval --strict home/modules/ai/default.nix`
- [ ] Home Manager builds: `home-manager build`
- [ ] No Home Manager activation errors: Check output of `home-manager switch`

#### Manual Verification:
- [ ] After logout/login, launchd agent is loaded: `launchctl list | grep io.crdant.env.ai`
- [ ] CLAUDE_CONFIG_DIR is set: `launchctl getenv CLAUDE_CONFIG_DIR` returns correct path based on username
- [ ] Claude Desktop app finds configuration correctly
- [ ] Claude Desktop app can access custom commands and agents
- [ ] No errors in log files: `cat ${config.xdg.stateHome}/launchd/env.ai.err`

---

## Phase 3: Add launchd Agent to kubernetes Module

### Overview
Add GUI environment support to the kubernetes module so GUI Kubernetes tools can find krew plugins.

### Changes Required

#### File: `home/modules/kubernetes/default.nix`

**Location:** After the `home.sessionPath` block (around line 33), add a new `launchd` block.

**Add this new configuration block:**

```nix
launchd = lib.mkIf isDarwin {
  enable = true;
  agents = {
    "io.crdant.env.kubernetes" = {
      enable = true;
      config = {
        Label = "io.crdant.env.kubernetes";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            # Add krew bin to PATH for GUI Kubernetes tools
            CURRENT_PATH=$(launchctl getenv PATH)
            if [[ -z "$CURRENT_PATH" ]]; then
              # If PATH doesn't exist yet, set a basic one
              launchctl setenv PATH "${config.home.homeDirectory}/.krew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            else
              # Prepend krew to existing PATH if not already present
              if [[ "$CURRENT_PATH" != *"${config.home.homeDirectory}/.krew/bin"* ]]; then
                launchctl setenv PATH "${config.home.homeDirectory}/.krew/bin:$CURRENT_PATH"
              fi
            fi
          ''
        ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.stateHome}/launchd/env.kubernetes.out";
        StandardErrorPath = "${config.xdg.stateHome}/launchd/env.kubernetes.err";
      };
    };
  };
};
```

**Important Notes:**
1. This agent checks if PATH already exists before modifying it
2. If base agent runs first, this will prepend to existing PATH
3. If this runs first, it sets a minimal PATH with krew
4. Avoids duplicate PATH entries with conditional check

### Success Criteria

#### Automated Verification:
- [ ] Nix configuration builds: `nix-instantiate --eval --strict home/modules/kubernetes/default.nix`
- [ ] Home Manager builds: `home-manager build`
- [ ] No Home Manager activation errors: Check output of `home-manager switch`

#### Manual Verification:
- [ ] After logout/login, launchd agent is loaded: `launchctl list | grep io.crdant.env.kubernetes`
- [ ] PATH includes krew: `launchctl getenv PATH` includes ~/.krew/bin
- [ ] No duplicate PATH entries: `launchctl getenv PATH | tr ':' '\n' | sort | uniq -d` returns nothing
- [ ] GUI Kubernetes tools (like Lens or Rancher Desktop UI) can find krew plugins
- [ ] No errors in log files: `cat ${config.xdg.stateHome}/launchd/env.kubernetes.err`

---

## Phase 4: Create Log Directory

### Overview
Ensure the launchd log directory exists before agents try to write to it.

### Changes Required

#### File: `home/modules/base/default.nix`

**Location:** In the `home.activation` block (around line 71-86), add a new entry.

**Add to the existing activation block:**

```nix
launchdLogDirectory = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
  mkdir -p ${config.xdg.stateHome}/launchd
'';
```

**Full context (showing where to add it):**

```nix
activation = {
  workspaceDirectory = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    mkdir -p ~/workspace
    mkdir -p ~/sandbox
  '';

  launchdLogDirectory = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    mkdir -p ${config.xdg.stateHome}/launchd
  '';

  customizeOmz = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "git" ] ''
    # ... existing customizeOmz code ...
  '';
};
```

### Success Criteria

#### Automated Verification:
- [ ] Directory is created during activation: `test -d ~/.local/state/launchd && echo "exists" || echo "missing"`
- [ ] Home Manager activation succeeds: `home-manager switch`

#### Manual Verification:
- [ ] Directory exists after home-manager switch
- [ ] Log files are created when agents run: `ls ~/.local/state/launchd/`
- [ ] Agents can write logs: Check that .out and .err files are being written to

---

## Testing Strategy

### Unit Tests
Not applicable - this is declarative configuration, not code.

### Integration Tests
Not applicable - Home Manager doesn't have a test framework for launchd agents.

### Manual Testing Steps

#### Step 1: Build and Activate Configuration
```bash
# Build the configuration first to catch syntax errors
home-manager build

# If build succeeds, activate it
home-manager switch
```

#### Step 2: Logout and Login
Launchd agents with `RunAtLoad = true` only execute at login, so you must:
```bash
# Option A: Logout from GUI and log back in
# Option B: Reboot the system
```

#### Step 3: Verify Agents Are Loaded
```bash
# Check all three agents are loaded
launchctl list | grep io.crdant.env

# Expected output:
# -    0    io.crdant.env.ai
# -    0    io.crdant.env.base
# -    0    io.crdant.env.kubernetes
```

#### Step 4: Verify Environment Variables
```bash
# Check each variable is set in GUI context
launchctl getenv PATH
launchctl getenv EDITOR
launchctl getenv VISUAL
launchctl getenv XDG_CONFIG_HOME
launchctl getenv CLAUDE_CONFIG_DIR

# PATH should include: ~/.local/bin, ~/workspace/go/bin, ~/.krew/bin, Homebrew paths
# EDITOR should be: nvim
# VISUAL should be: nvim
# XDG_CONFIG_HOME should be: /Users/chuck/.config
# CLAUDE_CONFIG_DIR should be: /Users/chuck/.config/claude/replicated (for chuck)
```

#### Step 5: Test with Real GUI Applications

**Test 1: VS Code**
1. Open VS Code from Finder or Spotlight (NOT from terminal)
2. Open integrated terminal
3. Run: `echo $PATH`
4. Verify it includes ~/.local/bin, ~/workspace/go/bin, ~/.krew/bin

**Test 2: Claude Desktop**
1. Launch Claude Desktop app
2. Check that it finds custom commands and agents
3. Verify it's using the correct config directory

**Test 3: Git GUI Operations**
1. Open any Git GUI client (GitHub Desktop, Fork, etc.)
2. Try to edit a commit message or create a new commit
3. Verify it opens nvim (not vim or nano)

**Test 4: Any App Spawning Editor**
1. Open any GUI app that might spawn an editor
2. Trigger editor launch (e.g., git commit in a GUI)
3. Verify EDITOR=nvim is respected

#### Step 6: Check for Errors
```bash
# Check log files for any errors
cat ~/.local/state/launchd/env.base.err
cat ~/.local/state/launchd/env.ai.err
cat ~/.local/state/launchd/env.kubernetes.err

# All should be empty or contain only harmless warnings
```

#### Step 7: Verify Shell Sessions Still Work
```bash
# Open a new terminal
# Verify shell environment is unchanged
echo $EDITOR    # Should be nvim
echo $PATH      # Should include all the custom paths
echo $XDG_CONFIG_HOME  # Should be set
```

## Performance Considerations

### Agent Execution Time
- Each agent executes a simple bash script with 1-4 `launchctl setenv` commands
- Expected execution time: < 100ms per agent
- Total overhead at login: < 300ms for all three agents
- This is negligible compared to typical macOS login time

### Memory Usage
- Launchd agents that have finished executing (`RunAtLoad=true` with no `KeepAlive`) do not consume memory
- Only the environment variables themselves consume memory (negligible: ~1KB total)

### PATH Order Concerns
- Multiple agents modifying PATH could create ordering issues
- Mitigation: kubernetes agent checks for existing PATH and appends (not replaces)
- If ordering becomes an issue, consider consolidating all PATH manipulation into base agent

## Migration Notes

### Backwards Compatibility
- Shell sessions are **completely unaffected** - all existing sessionVariables, sessionPath, and envExtra remain
- This is purely additive functionality
- Users who don't logout/login won't see any changes (graceful degradation)

### Rollback Plan
If issues occur:
1. Remove the `launchd` blocks from the three modules
2. Run `home-manager switch`
3. Logout/login to unload the agents
4. Environment returns to previous state (shell-only variables)

### Host Considerations
- These changes will apply to all Darwin hosts (aguardiente, grappa, sochu)
- All three hosts include the base, ai, and kubernetes modules
- No per-host customization needed

## References

- Original research: `docs/research/2025-10-18-darwin-desktop-app-environment.md`
- Existing launchd pattern: `home/modules/certificates/default.nix:46-78`
- Base module: `home/modules/base/default.nix:14-19` (sessionVariables)
- AI module: `home/modules/ai/default.nix:67-74` (CLAUDE_CONFIG_DIR logic)
- Kubernetes module: `home/modules/kubernetes/default.nix:30-32` (sessionPath)
- Home Manager launchd docs: https://nix-community.github.io/home-manager/options.xhtml#opt-launchd.agents
- macOS launchd docs: https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
