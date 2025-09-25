#!/bin/bash
# Test package installation on current platform
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <package_name>" >&2
    echo "Supported packages: vimr, replicated, kots, sbctl" >&2
    exit 1
fi

PACKAGE_NAME="$1"
PLATFORM="$(uname)"

echo "Testing $PACKAGE_NAME installation on $PLATFORM..."

# Map package name to Nix package name if needed
case "$PACKAGE_NAME" in
    "sbctl")
        NIX_PACKAGE="troubleshoot-sbctl"  # Note: matches the name in pkgs/default.nix
        BINARY_NAME="sbctl"
        ;;
    "kots")
        NIX_PACKAGE="kots"
        BINARY_NAME="kubectl-kots"  # KOTS installs as kubectl-kots
        ;;
    *)
        NIX_PACKAGE="$PACKAGE_NAME"
        BINARY_NAME="$PACKAGE_NAME"
        ;;
esac

echo "Building package: $NIX_PACKAGE"

# Build package using overlays (since packages aren't directly exposed in flake)
if ! nix build --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --no-link; then
    echo "❌ Failed to build $NIX_PACKAGE" >&2
    exit 1
fi

echo "✅ Package build successful"

# Test in shell - check if binary is available
echo "Testing binary availability: $BINARY_NAME"

if nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command which "$BINARY_NAME" >/dev/null 2>&1; then
    echo "✅ Binary $BINARY_NAME is available"
    
    # Try to get version info if possible
    echo "Attempting to get version info..."
    if nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command "$BINARY_NAME" --version >/dev/null 2>&1; then
        VERSION_INFO=$(nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command "$BINARY_NAME" --version 2>/dev/null || echo "Version info unavailable")
        echo "Version: $VERSION_INFO"
    elif nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command "$BINARY_NAME" version >/dev/null 2>&1; then
        VERSION_INFO=$(nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command "$BINARY_NAME" version 2>/dev/null || echo "Version info unavailable")
        echo "Version: $VERSION_INFO"
    elif nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command "$BINARY_NAME" --help >/dev/null 2>&1; then
        echo "✅ Help command works (version command not available)"
    else
        echo "⚠️  Binary executes but version/help commands may not work"
    fi
else
    echo "❌ Binary $BINARY_NAME not found after installation" >&2
    exit 1
fi

# Platform-specific checks
case "$PACKAGE_NAME" in
    "vimr")
        if [ "$PLATFORM" != "Darwin" ]; then
            echo "⚠️  VimR is macOS-only, but test ran on $PLATFORM"
            echo "This suggests the package may not have proper platform restrictions"
        else
            echo "✅ VimR tested on correct platform (macOS)"
            
            # Check if VimR app bundle exists  
            if nix shell --impure --expr "let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.$NIX_PACKAGE" --command ls -la /nix/store/*/Applications/VimR.app 2>/dev/null; then
                echo "✅ VimR app bundle structure verified"
            else
                echo "⚠️  VimR app bundle structure could not be verified"
            fi
        fi
        ;;
    "replicated"|"kots"|"sbctl")
        if [ "$PLATFORM" = "Darwin" ] || [ "$PLATFORM" = "Linux" ]; then
            echo "✅ $PACKAGE_NAME tested on supported platform ($PLATFORM)"
        else
            echo "⚠️  $PACKAGE_NAME tested on unexpected platform: $PLATFORM"
        fi
        ;;
esac

echo "✅ $PACKAGE_NAME installation test passed on $PLATFORM"