---
date: 2025-10-02T01:18:18+0000
researcher: Claude
git_commit: 9a40fa1befa345f70544bbcccab27e631633a99a
branch: feature/crdant/installs-codelayer
repository: crdant/dotfiles
topic: "Why isn't Tailscale being compiled with Go 1.25?"
tags: [research, codebase, tailscale, go, overlays, bug]
status: complete
last_updated: 2025-10-01
last_updated_by: Claude
---

# Research: Why isn't Tailscale being compiled with Go 1.25?

**Date**: 2025-10-02T01:18:18+0000
**Researcher**: Claude
**Git Commit**: 9a40fa1befa345f70544bbcccab27e631633a99a
**Branch**: feature/crdant/installs-codelayer
**Repository**: crdant/dotfiles

## Research Question
Why isn't Tailscale being compiled with Go 1.25, despite overlays suggesting it should be?

## Summary

**Root Cause Found**: There is a bug in the overlay configuration at `overlays/default.nix:23`.

The `buildGo1_25Module` function references `final.go` (the default Go version) instead of `final.go1_25` (the custom Go 1.25 compiler). This means Tailscale and other packages configured to use `buildGo1_25Module` are actually being compiled with the default Go version from nixpkgs, not Go 1.25.1 as intended.

**Fix Required**: Change line 23 from:
```nix
go = final.go;
```
to:
```nix
go = final.go1_25;
```

## Detailed Findings

### The Bug: Wrong Go Compiler Reference

**File**: `overlays/default.nix:22-24`

**Current (Incorrect) Code**:
```nix
buildGo1_25Module = prev.buildGoModule.override {
  go = final.go;  # ❌ References default Go, not Go 1.25
};
```

**Should Be**:
```nix
buildGo1_25Module = prev.buildGoModule.override {
  go = final.go1_25;  # ✅ References the custom Go 1.25 compiler
};
```

### How the Overlay Should Work

#### Step 1: Custom Go 1.25 Compiler Definition
**File**: `overlays/default.nix:10-20`

The overlay correctly defines a custom Go 1.25.1 compiler:

```nix
go1_25 = prev.go.overrideAttrs (oldAttrs: let
  newVersion = "1.25.1";
  in {
    version = newVersion;
    src = prev.fetchzip {
      url = "https://go.dev/dl/go${newVersion}.src.tar.gz";
      hash = "sha256-jz/CjhXI4jMFHhg7Up/X1FbUyMRTFM1fim3Gj77cU9Q=";
    };
    patches = [];
  }
);
```

This creates `final.go1_25` - a working Go 1.25.1 compiler.

#### Step 2: Custom Build Function (BUGGY)
**File**: `overlays/default.nix:22-24`

The custom build function is created but with the wrong Go reference:

```nix
buildGo1_25Module = prev.buildGoModule.override {
  go = final.go;  # BUG: Should be final.go1_25
};
```

**What happens**:
- `prev.buildGoModule` is the standard Nix Go build function
- `.override { go = ... }` replaces the Go compiler used by this function
- `final.go` resolves to the default Go package from nixpkgs (likely Go 1.22 or 1.23)
- `final.go1_25` would resolve to the custom Go 1.25.1 defined above

#### Step 3: Tailscale Package Override
**File**: `overlays/default.nix:38-50`

Tailscale is configured to use the buggy build function:

```nix
tailscale = (prev.tailscale.overrideAttrs (oldAttrs: let
  newVersion = "1.88.3";
in {
  version = newVersion;
  src = prev.fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${newVersion}";
    sha256 = "sha256-gw4oexTyJGeBkCd07RQQdfY14xArgVIMDHKrWu9K+9Q=";
  };
  vendorHash = "sha256-8aE6dWMkTLdWRD9WnLVSzpOQQh61voEnjZAJHtbGCSs=";
  doCheck = false;
})).override{ buildGoModule = final.buildGo1_25Module; };
```

**What this does**:
1. Updates Tailscale to version 1.88.3 (first override)
2. Replaces the build function with `buildGo1_25Module` (second override)
3. But because `buildGo1_25Module` uses the wrong Go compiler, Tailscale builds with default Go

#### Step 4: KOTS Also Affected
**File**: `overlays/default.nix:52`

```nix
kots = prev.kots.override{ buildGoModule = final.buildGo1_25Module; };
```

KOTS is also configured to use `buildGo1_25Module`, so it's also building with the wrong Go version.

### Overlay Application Architecture

The overlays are applied at multiple levels in the configuration:

#### System Level (Darwin)
**File**: `systems/modules/base/default.nix:41-59`

```nix
nixpkgs.overlays = [
  outputs.overlays.additions
  outputs.overlays.modifications  # Contains the buggy buildGo1_25Module
  outputs.overlays.unstable-packages
  outputs.overlays.nur-packages
];
```

#### System Level (NixOS)
**File**: `systems/modules/nix-core/default.nix:12-27`

```nix
nixpkgs.overlays = [
  outputs.overlays.additions
  outputs.overlays.modifications  # Contains the buggy buildGo1_25Module
  outputs.overlays.unstable-packages
];
```

#### Home Manager Level
**File**: `home/modules/base/default.nix:90-98`

```nix
nixpkgs.overlays = [
  outputs.overlays.additions
  outputs.overlays.modifications  # Contains the buggy buildGo1_25Module
  outputs.overlays.unstable-packages
  outputs.overlays.nur-packages
];
```

The bug propagates to all configuration levels because they all import the same `modifications` overlay.

### Affected Packages

**Currently Configured to Use Go 1.25 (but don't due to bug)**:
1. `tailscale` - Version 1.88.3 (`overlays/default.nix:50`)
2. `kots` - (`overlays/default.nix:52`)

**Other Go Packages (Using Default Go)**:
- `imgpkg` - `pkgs/imgpkg/default.nix`
- `replicated` - `pkgs/replicated/default.nix`
- `tunnelmanager` - `pkgs/tunnelmanager/default.nix`
- `mbta-mcp-server` - `pkgs/mbta-mcp-server/default.nix`
- `leftovers` - `pkgs/leftovers/default.nix`

These packages use standard `buildGoModule` and are not intended to use Go 1.25.

### Why This Bug is Subtle

1. **Valid Nix Syntax**: The code `go = final.go;` is syntactically correct - `final.go` exists in nixpkgs
2. **No Build Errors**: Tailscale builds successfully, just with the wrong Go version
3. **Overlay Fixpoint Confusion**: In overlays, `final` refers to the fully composed package set, but it's easy to forget that `final.go` and `final.go1_25` are different
4. **No Runtime Issues**: Tailscale works fine even with the wrong Go version, making the bug invisible

### How to Verify the Fix

After applying the fix, you can verify the Go version used by Tailscale:

```bash
# Check the Go version in the Tailscale binary metadata
nix-store -q --tree $(which tailscale) | grep -i go

# Or build with verbose output
nix build .#darwinConfigurations.<hostname>.system --show-trace
```

The build should show Go 1.25.1 being used instead of the default Go version.

## Code References

- `overlays/default.nix:23` - **BUG**: Wrong Go compiler reference
- `overlays/default.nix:10-20` - Custom Go 1.25 compiler definition
- `overlays/default.nix:22-24` - Buggy buildGo1_25Module definition
- `overlays/default.nix:38-50` - Tailscale override using buggy builder
- `overlays/default.nix:52` - KOTS override using buggy builder
- `systems/modules/base/default.nix:41-59` - Darwin overlay application
- `systems/modules/nix-core/default.nix:12-27` - NixOS overlay application
- `home/modules/base/default.nix:90-98` - Home Manager overlay application

## Architecture Insights

### Overlay Composition Pattern

The dotfiles use a multi-overlay architecture:

1. **`additions`** - Imports custom packages from `pkgs/`
2. **`modifications`** - Overrides existing nixpkgs packages (contains the bug)
3. **`unstable-packages`** - Provides access to nixpkgs-unstable via `pkgs.unstable`
4. **`nur-packages`** - Provides NUR packages via `pkgs.nur`

Overlays are applied in this order, allowing later overlays to reference earlier ones via the `final` fixpoint.

### Double Override Pattern

Tailscale uses a sophisticated double-override pattern:

1. **First override** (`overrideAttrs`): Updates package attributes (version, source, vendorHash)
2. **Second override** (`.override`): Replaces the build function parameter

This pattern allows changing both what to build (version/source) and how to build it (compiler) independently.

### Fixpoint Resolution

In Nix overlays:
- `prev` refers to the previous overlay layer (or base nixpkgs if first)
- `final` refers to the fully composed result after all overlays

The bug occurs because:
- `final.go1_25` exists and contains Go 1.25.1 (defined in same overlay)
- `final.go` exists and contains default Go from nixpkgs
- Using `final.go` instead of `final.go1_25` is valid but wrong

## Historical Context

**No previous documentation found** for:
- This specific overlay bug
- Tailscale Go version issues
- buildGoModule override problems

**Related Documentation**:
- `thoughts/shared/plans/2025-01-22-package-update-workflows.md` - Documents pattern of handling vendorHash for Go packages
- `docs/research/2025-10-01-auto-update-configuration.md` - Documents auto-update mechanism (Tailscale updates via system auto-upgrade)

## Related Research

- `docs/research/2025-10-01-auto-update-configuration.md` - Auto-update configuration research

## Open Questions

1. **Was Go 1.25 chosen for a specific reason?** (e.g., Tailscale compatibility, performance, bug fixes)
2. **Should other Go packages also use Go 1.25?** (replicated, imgpkg, etc.)
3. **How long has this bug existed?** (git history check recommended)
4. **Are there any functional differences between Tailscale built with default Go vs Go 1.25?**

## Recommended Actions

1. **Immediate**: Fix line 23 in `overlays/default.nix` to use `final.go1_25`
2. **Verify**: Rebuild and confirm Tailscale uses Go 1.25.1
3. **Test**: Ensure Tailscale still functions correctly after the fix
4. **Document**: Add comment explaining why Go 1.25 is needed
5. **Review**: Check if other packages should also use Go 1.25
