#!/usr/bin/env python3
"""
Calculate vendorHash for Go modules on specific platforms.
This script is used by GitHub Actions workflows to determine platform-specific vendor hashes.
"""

import os
import sys
import re
import tempfile
import subprocess
import shutil
from pathlib import Path

def calculate_vendor_hash(owner: str, repo: str, version: str, platform: str, proxy_vendor: bool = False) -> str:
    """Calculate vendorHash for Go module on specific platform.

    Args:
        owner: GitHub repository owner
        repo: GitHub repository name
        version: Semver version string
        platform: Platform identifier (e.g., 'macos-latest', 'ubuntu-latest')
        proxy_vendor: If True, calculate hash for proxyVendor mode (go mod download cache),
                     otherwise calculate hash for vendor directory mode
    """

    # Validate version format (should be semver-like: X.Y.Z or X.Y.Z-suffix)
    if not re.match(r'^[\d]+\.[\d]+\.[\d]+(-[\w.]+)?$', version):
        raise ValueError(f"Invalid version format: {version}. Expected semver format (e.g., 1.2.3 or 1.2.3-beta.1)")

    mode_str = "proxyVendor" if proxy_vendor else "vendor directory"
    print(f"Calculating vendor hash for {owner}/{repo} v{version} on {platform} (mode: {mode_str})")
    
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        repo_path = temp_path / repo
        
        # Clone the repository at specific version
        print("Cloning repository...")
        subprocess.run([
            "git", "clone", "--depth", "1", "--branch", f"v{version}",
            f"https://github.com/{owner}/{repo}.git",
            str(repo_path)
        ], check=True, capture_output=True)
        
        # Change to repo directory
        os.chdir(repo_path)
        
        # Ensure go.mod and go.sum exist
        if not (repo_path / "go.mod").exists():
            raise RuntimeError(f"No go.mod found in {owner}/{repo}")
        
        # Set up GOPATH for module downloads
        gopath = temp_path / "gopath"
        gopath.mkdir()
        os.environ["GOPATH"] = str(gopath)

        # Download dependencies
        print("Downloading Go dependencies...")
        result = subprocess.run(["go", "mod", "download"], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Go mod download failed with stderr:\n{result.stderr}", file=sys.stderr)
            raise RuntimeError(f"go mod download failed with exit code {result.returncode}")

        if proxy_vendor:
            # For proxyVendor mode, hash the Go module download cache
            print("Calculating hash of Go module cache (proxyVendor mode)...")

            # The Go module cache is in GOPATH/pkg/mod
            mod_cache = gopath / "pkg" / "mod"

            if not mod_cache.exists():
                raise RuntimeError("Go module cache not found after download")

            # Hash the module cache directory
            result = subprocess.run([
                "nix-hash", "--type", "sha256", "--base32", str(mod_cache)
            ], capture_output=True, text=True, check=True)

            vendor_hash_base32 = result.stdout.strip()
        else:
            # For standard vendor mode, create and hash vendor directory
            print("Creating vendor directory...")
            try:
                result = subprocess.run(
                    ["go", "mod", "vendor"],
                    capture_output=True,
                    text=True,
                    check=True
                )
                print("Vendor directory created successfully")
            except subprocess.CalledProcessError as e:
                print(f"ERROR: go mod vendor failed with exit code {e.returncode}", file=sys.stderr)
                if e.stderr:
                    print(f"Error output:\n{e.stderr}", file=sys.stderr)
                if e.stdout:
                    print(f"Standard output:\n{e.stdout}", file=sys.stderr)
                raise

            # Calculate hash of vendor directory
            print("Calculating hash of vendor directory...")

            # Create a reproducible hash of the vendor directory
            # We need to use nix-hash for consistency with Nix builds
            result = subprocess.run([
                "nix-hash", "--type", "sha256", "--base32", "vendor"
            ], capture_output=True, text=True, check=True)

            vendor_hash_base32 = result.stdout.strip()

        # Convert to SRI format
        convert_result = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            vendor_hash_base32
        ], capture_output=True, text=True, check=True)

        sri_hash = convert_result.stdout.strip()

        print(f"Calculated vendor hash: {sri_hash}")
        return sri_hash

def main():
    """Main entry point."""
    if len(sys.argv) < 4 or len(sys.argv) > 5:
        print("Usage: calculate-go-vendor-hash.py <package_name> <version> <platform> [--proxy-vendor]", file=sys.stderr)
        print("Example: calculate-go-vendor-hash.py replicated 0.114.0 macos-latest", file=sys.stderr)
        print("Example: calculate-go-vendor-hash.py replicated 0.120.0 macos-latest --proxy-vendor", file=sys.stderr)
        sys.exit(1)

    package_name = sys.argv[1]
    version = sys.argv[2]
    platform = sys.argv[3]
    proxy_vendor = len(sys.argv) == 5 and sys.argv[4] == "--proxy-vendor"
    
    # Map package name to GitHub repo
    repo_map = {
        "replicated": ("replicatedhq", "replicated"),
        "kots": ("replicatedhq", "kots")
    }
    
    if package_name not in repo_map:
        print(f"Unknown package: {package_name}", file=sys.stderr)
        print(f"Supported packages: {', '.join(repo_map.keys())}", file=sys.stderr)
        sys.exit(1)
    
    owner, repo = repo_map[package_name]

    try:
        vendor_hash = calculate_vendor_hash(owner, repo, version, platform, proxy_vendor)
        
        # Set GitHub Actions output
        if os.environ.get("GITHUB_ACTIONS"):
            platform_key = "darwin" if "macos" in platform else "linux"
            
            with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                f.write(f"{platform_key}-hash={vendor_hash}\n")
                f.write(f"vendor-hash={vendor_hash}\n")
        
        print(f"Vendor hash for {package_name} v{version} on {platform}: {vendor_hash}")
        
    except Exception as e:
        print(f"Failed to calculate vendor hash: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
