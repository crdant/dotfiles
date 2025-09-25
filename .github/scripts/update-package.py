#!/usr/bin/env python3
"""
Package update utility for dotfiles repository.
Supports different package types: binary, go-module
"""

import json
import subprocess
import sys
import os
import re
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
import requests
from datetime import datetime

def get_github_headers() -> Dict[str, str]:
    """Get GitHub API headers with authentication if token is available."""
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "package-updater/1.0"
    }
    
    # Check for GitHub token in environment variables
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GITHUB_AUTH_TOKEN")
    
    if token:
        headers["Authorization"] = f"token {token}"
        print("Using authenticated GitHub API requests")
    else:
        print("Warning: No GitHub token found. Using unauthenticated requests (rate limited to 60/hour)")
        print("Set GITHUB_TOKEN or GITHUB_AUTH_TOKEN environment variable for higher rate limits")
    
    return headers

def check_rate_limit() -> None:
    """Check and display current GitHub API rate limit status."""
    headers = get_github_headers()
    
    try:
        response = requests.get("https://api.github.com/rate_limit", headers=headers)
        response.raise_for_status()
        rate_data = response.json()
        
        core_limit = rate_data["resources"]["core"]
        remaining = core_limit["remaining"]
        limit = core_limit["limit"]
        reset_time = datetime.fromtimestamp(core_limit["reset"])
        
        print(f"GitHub API rate limit: {remaining}/{limit} remaining")
        if remaining < 10:
            print(f"Warning: Low rate limit! Resets at {reset_time}")
        
    except requests.RequestException as e:
        print(f"Could not check rate limit: {e}", file=sys.stderr)

def get_latest_release(owner: str, repo: str) -> Dict[str, Any]:
    """Get latest release info from GitHub API."""
    headers = get_github_headers()
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    
    try:
        response = requests.get(url, headers=headers)
        
        # Handle rate limiting
        if response.status_code == 403 and "rate limit exceeded" in response.text.lower():
            reset_time = datetime.fromtimestamp(int(response.headers.get("X-RateLimit-Reset", 0)))
            print(f"Rate limit exceeded! Resets at {reset_time}", file=sys.stderr)
            print("Please wait or set a GitHub token in GITHUB_TOKEN environment variable", file=sys.stderr)
            sys.exit(1)
        
        response.raise_for_status()
        return response.json()
        
    except requests.RequestException as e:
        if hasattr(e, 'response') and e.response is not None:
            if e.response.status_code == 404:
                print(f"No releases found for {owner}/{repo}", file=sys.stderr)
            elif e.response.status_code == 403:
                print(f"Access forbidden (rate limit?): {owner}/{repo}", file=sys.stderr)
                remaining = e.response.headers.get("X-RateLimit-Remaining", "unknown")
                print(f"Rate limit remaining: {remaining}", file=sys.stderr)
        raise

def calculate_binary_hash(url: str) -> str:
    """Calculate hash for a binary download using nix-prefetch-url."""
    try:
        result = subprocess.run([
            "nix-prefetch-url", "--type", "sha256", url
        ], capture_output=True, text=True, check=True)
        
        # Convert to SRI format
        convert_result = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            result.stdout.strip()
        ], capture_output=True, text=True, check=True)
        
        return convert_result.stdout.strip()
        
    except subprocess.CalledProcessError as e:
        print(f"Failed to calculate hash for {url}: {e}", file=sys.stderr)
        raise

def calculate_go_source_hash(owner: str, repo: str, rev: str) -> str:
    """Calculate hash for a Go source repository using nix-prefetch-git."""
    try:
        result = subprocess.run([
            "nix-prefetch-git", 
            "--url", f"https://github.com/{owner}/{repo}",
            "--rev", rev,
            "--quiet"
        ], capture_output=True, text=True, check=True)
        
        prefetch_data = json.loads(result.stdout)
        
        # Convert to SRI format
        convert_result = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            prefetch_data["sha256"]
        ], capture_output=True, text=True, check=True)
        
        return convert_result.stdout.strip()
        
    except subprocess.CalledProcessError as e:
        print(f"Failed to calculate source hash for {owner}/{repo}@{rev}: {e}", file=sys.stderr)
        raise

def read_current_version(package_path: Path) -> Optional[Dict[str, str]]:
    """Read current version information from package file."""
    try:
        with package_path.open() as f:
            content = f.read()
        
        # Extract version information
        version_match = re.search(r'version\s*=\s*"([^"]+)"', content)
        if not version_match:
            print(f"Could not find version in {package_path}", file=sys.stderr)
            return None
        
        version = version_match.group(1)
        
        # Extract build for VimR
        build_match = re.search(r'build\s*=\s*"([^"]+)"', content)
        build = build_match.group(1) if build_match else None
        
        return {"version": version, "build": build}
        
    except Exception as e:
        print(f"Failed to read {package_path}: {e}", file=sys.stderr)
        return None

def update_vimr(package_path: Path) -> Optional[Dict[str, str]]:
    """Update VimR package with latest release info."""
    print("Checking for VimR updates...")
    
    current = read_current_version(package_path)
    if not current:
        return None
    
    # Get latest release
    try:
        release = get_latest_release("qvacua", "vimr")
    except Exception as e:
        print(f"Failed to get VimR release info: {e}", file=sys.stderr)
        return None
    
    # Parse version and build from release tag (e.g., "v0.57.0-20250901.212156")
    tag_name = release["tag_name"]
    version_pattern = r'v(\d+\.\d+\.\d+)-(\d+\.\d+)'
    match = re.match(version_pattern, tag_name)
    
    if not match:
        print(f"Could not parse VimR version from tag: {tag_name}", file=sys.stderr)
        return None
        
    new_version = f"v{match.group(1)}"
    new_build = match.group(2)
    
    # Check if update is needed
    if current["version"] == new_version and current["build"] == new_build:
        print(f"VimR is already up to date: {new_version}-{new_build}")
        return None
    
    print(f"VimR update available: {current['version']}-{current['build']} -> {new_version}-{new_build}")
    
    # Calculate new hash
    download_url = f"https://github.com/qvacua/vimr/releases/download/{tag_name}/VimR-{new_version}.tar.bz2"
    try:
        new_hash = calculate_binary_hash(download_url)
    except Exception as e:
        print(f"Failed to calculate VimR hash: {e}", file=sys.stderr)
        return None
    
    # Update package file
    try:
        with package_path.open() as f:
            content = f.read()
        
        # Update version, build, and hash
        content = re.sub(r'version\s*=\s*"[^"]+";', f'version = "{new_version}";', content)
        content = re.sub(r'build\s*=\s*"[^"]+";', f'build = "{new_build}";', content)
        content = re.sub(r'sha256\s*=\s*"[^"]+";', f'sha256 = "{new_hash}";', content)
        
        with package_path.open("w") as f:
            f.write(content)
            
        print(f"Updated VimR package to {new_version}-{new_build}")
        
        # Set GitHub Actions outputs
        if os.environ.get("GITHUB_ACTIONS"):
            with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                f.write(f"updated=true\n")
                f.write(f"old-version={current['version']}-{current['build']}\n")
                f.write(f"new-version={new_version}-{new_build}\n")
        
        return {
            "old_version": f"{current['version']}-{current['build']}",
            "new_version": f"{new_version}-{new_build}",
            "updated": True
        }
        
    except Exception as e:
        print(f"Failed to update VimR package file: {e}", file=sys.stderr)
        return None

def update_go_package(package_path: Path, owner: str, repo: str) -> Optional[Dict[str, str]]:
    """Update Go module package with latest release info."""
    package_name = package_path.parent.name
    print(f"Checking for {package_name} updates...")
    
    current = read_current_version(package_path)
    if not current:
        return None
    
    # Get latest release
    try:
        release = get_latest_release(owner, repo)
    except Exception as e:
        print(f"Failed to get {package_name} release info: {e}", file=sys.stderr)
        return None
    
    # Parse version from tag (e.g., "v0.114.0" -> "0.114.0")
    tag_name = release["tag_name"]
    new_version = tag_name.lstrip("v")
    
    # Check if update is needed
    if current["version"] == new_version:
        print(f"{package_name} is already up to date: {new_version}")
        return None
    
    print(f"{package_name} update available: {current['version']} -> {new_version}")
    
    # Calculate new source hash
    try:
        new_source_hash = calculate_go_source_hash(owner, repo, tag_name)
    except Exception as e:
        print(f"Failed to calculate {package_name} source hash: {e}", file=sys.stderr)
        return None
    
    # Update package file
    try:
        with package_path.open() as f:
            content = f.read()
        
        # Update version and source hash
        content = re.sub(r'version\s*=\s*"[^"]+";', f'version = "{new_version}";', content)
        content = re.sub(r'sha256\s*=\s*"[^"]+";', f'sha256 = "{new_source_hash}";', content)
        
        with package_path.open("w") as f:
            f.write(content)
            
        print(f"Updated {package_name} package to {new_version} (source hash updated)")
        print("Note: vendorHash will be updated by separate workflow job")
        
        # Set GitHub Actions outputs
        if os.environ.get("GITHUB_ACTIONS"):
            with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                f.write(f"updated=true\n")
                f.write(f"old-version={current['version']}\n")
                f.write(f"new-version={new_version}\n")
                f.write(f"tag-name={tag_name}\n")
        
        return {
            "old_version": current["version"],
            "new_version": new_version,
            "tag_name": tag_name,
            "updated": True
        }
        
    except Exception as e:
        print(f"Failed to update {package_name} package file: {e}", file=sys.stderr)
        return None

def update_sbctl(package_path: Path) -> Optional[Dict[str, str]]:
    """Update sbctl package with latest release info."""
    print("Checking for sbctl updates...")
    
    current = read_current_version(package_path)
    if not current:
        return None
    
    # Get latest release
    try:
        release = get_latest_release("replicatedhq", "sbctl")
    except Exception as e:
        print(f"Failed to get sbctl release info: {e}", file=sys.stderr)
        return None
    
    # Parse version from tag (e.g., "v0.17.3" -> "0.17.3")
    tag_name = release["tag_name"]
    new_version = tag_name.lstrip("v")
    
    # Check if update is needed
    if current["version"] == new_version:
        print(f"sbctl is already up to date: {new_version}")
        return None
    
    print(f"sbctl update available: {current['version']} -> {new_version}")
    
    # Calculate new hashes for both platforms
    darwin_url = f"https://github.com/replicatedhq/sbctl/releases/download/{tag_name}/sbctl_darwin_amd64.tar.gz"
    linux_url = f"https://github.com/replicatedhq/sbctl/releases/download/{tag_name}/sbctl_linux_amd64.tar.gz"
    
    try:
        print("Calculating Darwin hash...")
        darwin_result = subprocess.run([
            "nix-prefetch-url", "--type", "sha256", "--unpack", darwin_url
        ], capture_output=True, text=True, check=True)
        
        darwin_convert = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            darwin_result.stdout.strip()
        ], capture_output=True, text=True, check=True)
        
        darwin_hash = darwin_convert.stdout.strip()
        
        print("Calculating Linux hash...")
        linux_result = subprocess.run([
            "nix-prefetch-url", "--type", "sha256", "--unpack", linux_url
        ], capture_output=True, text=True, check=True)
        
        linux_convert = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            linux_result.stdout.strip()
        ], capture_output=True, text=True, check=True)
        
        linux_hash = linux_convert.stdout.strip()
        
    except subprocess.CalledProcessError as e:
        print(f"Failed to calculate sbctl hashes: {e}", file=sys.stderr)
        return None
    
    # Update package file
    try:
        with package_path.open() as f:
            content = f.read()
        
        # Update version and platform-specific hashes
        content = re.sub(r'version\s*=\s*"[^"]+";', f'version = "{new_version}";', content)
        
        # Update Darwin hash
        content = re.sub(
            r'(sha256\s*=\s*if\s+isDarwin\s+then\s*)"[^"]+"\s*else',
            f'\\1"{darwin_hash}"\n      else',
            content
        )
        
        # Update Linux hash
        content = re.sub(
            r'(else\s*)"[^"]+";',
            f'\\1"{linux_hash}";',
            content
        )
        
        with package_path.open("w") as f:
            f.write(content)
            
        print(f"Updated sbctl package to {new_version}")
        
        # Set GitHub Actions outputs
        if os.environ.get("GITHUB_ACTIONS"):
            with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                f.write(f"updated=true\n")
                f.write(f"old-version={current['version']}\n")
                f.write(f"new-version={new_version}\n")
                f.write(f"darwin-hash={darwin_hash}\n")
                f.write(f"linux-hash={linux_hash}\n")
        
        return {
            "old_version": current["version"],
            "new_version": new_version,
            "darwin_hash": darwin_hash,
            "linux_hash": linux_hash,
            "updated": True
        }
        
    except Exception as e:
        print(f"Failed to update sbctl package file: {e}", file=sys.stderr)
        return None

def main():
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Usage: update-package.py <package_name>", file=sys.stderr)
        print("Supported packages: vimr, replicated, kots, sbctl", file=sys.stderr)
        sys.exit(1)
    
    package_name = sys.argv[1]
    
    # Check rate limit before starting
    check_rate_limit()
    
    # Get package path
    if package_name == "sbctl":
        # Note: the package directory is named sbctl but the package name in default.nix is troubeleshoot-sbctl
        package_path = Path("pkgs/sbctl/default.nix")
    else:
        package_path = Path(f"pkgs/{package_name}/default.nix")
    
    if not package_path.exists():
        print(f"Package file not found: {package_path}", file=sys.stderr)
        sys.exit(1)
    
    # Update based on package type
    result = None
    if package_name == "vimr":
        result = update_vimr(package_path)
    elif package_name == "replicated":
        result = update_go_package(package_path, "replicatedhq", "replicated")
    elif package_name == "kots":
        result = update_go_package(package_path, "replicatedhq", "kots")
    elif package_name == "sbctl":
        result = update_sbctl(package_path)
    else:
        print(f"Unknown package: {package_name}", file=sys.stderr)
        sys.exit(1)
    
    # Set default outputs for GitHub Actions if no update was found
    if not result and os.environ.get("GITHUB_ACTIONS"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write("updated=false\n")
    
    print("Package update check completed.")

if __name__ == "__main__":
    main()