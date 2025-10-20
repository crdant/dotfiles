#!/usr/bin/env python3
"""
Calculate vendorHash for Go modules on specific platforms.
This script is used by GitHub Actions workflows to determine platform-specific vendor hashes.
"""

import os
import sys
import tempfile
import subprocess
import shutil
from pathlib import Path

def calculate_vendor_hash(owner: str, repo: str, version: str, platform: str) -> str:
    """Calculate vendorHash for Go module on specific platform."""
    
    print(f"Calculating vendor hash for {owner}/{repo} v{version} on {platform}")
    
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
        
        # Download dependencies
        print("Downloading Go dependencies...")
        subprocess.run(["go", "mod", "download"], check=True, capture_output=True)
        
        # Use go mod vendor to create vendor directory
        print("Creating vendor directory...")
        subprocess.run(["go", "mod", "vendor"], check=True, capture_output=True)
        
        # Calculate hash of vendor directory
        print("Calculating vendor hash...")
        
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
    if len(sys.argv) != 4:
        print("Usage: calculate-go-vendor-hash.py <package_name> <version> <platform>", file=sys.stderr)
        print("Example: calculate-go-vendor-hash.py replicated 0.114.0 macos-latest", file=sys.stderr)
        sys.exit(1)
    
    package_name = sys.argv[1]
    version = sys.argv[2] 
    platform = sys.argv[3]
    
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
        vendor_hash = calculate_vendor_hash(owner, repo, version, platform)
        
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