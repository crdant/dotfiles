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
from typing import Dict, Any, Optional, Tuple, List
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

def discover_available_packages() -> Dict[str, Dict[str, Any]]:
    """Discover all available packages from pkgs/ directory and their types."""
    packages = {}
    pkgs_dir = Path("pkgs")
    
    if not pkgs_dir.exists():
        return packages
    
    for pkg_dir in pkgs_dir.iterdir():
        if not pkg_dir.is_dir() or pkg_dir.name in ['llm', '__pycache__']:
            continue
            
        default_nix = pkg_dir / "default.nix"
        if not default_nix.exists():
            continue
            
        try:
            with default_nix.open() as f:
                content = f.read()
            
            # Determine package type and metadata
            pkg_info = analyze_package_file(content, pkg_dir.name)
            if pkg_info:
                packages[pkg_dir.name] = pkg_info
                packages[pkg_dir.name]["path"] = default_nix
                
        except Exception as e:
            print(f"Warning: Could not analyze package {pkg_dir.name}: {e}", file=sys.stderr)
            continue
    
    return packages

def analyze_package_file(content: str, dir_name: str) -> Optional[Dict[str, Any]]:
    """Analyze a package file to determine its type and metadata."""
    # Extract version information
    version_match = re.search(r'version\s*=\s*"([^"]+)"', content)
    if not version_match:
        return None
    
    version = version_match.group(1)
    
    # Extract build for VimR-style packages
    build_match = re.search(r'build\s*=\s*"([^"]+)"', content)
    build = build_match.group(1) if build_match else None
    
    # Determine package type based on patterns
    if 'fetchurl' in content and 'VimR' in content:
        pkg_type = 'vimr-binary'
    elif 'buildGoModule' in content and 'vendorHash' in content:
        # Check if it has platform-specific vendorHash
        if 'if isDarwin then' in content and 'vendorHash' in content:
            pkg_type = 'go-module-platform-specific'
        else:
            pkg_type = 'go-module-simple'
    elif 'fetchzip' in content and ('darwin' in content or 'linux' in content):
        pkg_type = 'pre-built-binary'
    elif 'fetchFromGitHub' in content:
        pkg_type = 'github-source'
    else:
        pkg_type = 'unknown'
    
    # Extract GitHub repository info if present
    owner_match = re.search(r'owner\s*=\s*"([^"]+)"', content)
    repo_match = re.search(r'repo\s*=\s*"([^"]+)"', content)
    
    return {
        "type": pkg_type,
        "version": version,
        "build": build,
        "owner": owner_match.group(1) if owner_match else None,
        "repo": repo_match.group(1) if repo_match else None,
        "directory": dir_name
    }

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

def update_github_source_package(pkg_info: Dict[str, Any]) -> Optional[Dict[str, str]]:
    """Update a GitHub source package with latest release info."""
    package_name = pkg_info["directory"]
    package_path = pkg_info["path"]
    owner = pkg_info["owner"]
    repo = pkg_info["repo"]
    
    if not owner or not repo:
        print(f"No GitHub owner/repo found for {package_name}", file=sys.stderr)
        return None
        
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
        content = re.sub(r'(sha256|hash)\s*=\s*"[^"]+";', f'hash = "{new_source_hash}";', content)
        
        with package_path.open("w") as f:
            f.write(content)
            
        print(f"Updated {package_name} package to {new_version} (source hash updated)")
        if pkg_info["type"] in ["go-module-platform-specific", "go-module-simple"]:
            print("Note: vendorHash will be updated by separate workflow job if needed")
        
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

def update_go_package(package_path: Path, owner: str, repo: str) -> Optional[Dict[str, str]]:
    """Legacy wrapper for backwards compatibility."""
    pkg_info = {
        "directory": package_path.parent.name,
        "path": package_path,
        "owner": owner,
        "repo": repo,
        "type": "go-module-simple"
    }
    return update_github_source_package(pkg_info)

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
    if len(sys.argv) < 2:
        available_packages = discover_available_packages()
        print("Usage: update-package.py <package_name>", file=sys.stderr)
        print(f"Available packages: {', '.join(sorted(available_packages.keys()))}", file=sys.stderr)
        sys.exit(1)
    
    package_name = sys.argv[1]
    
    # Discover available packages
    available_packages = discover_available_packages()
    
    if package_name not in available_packages:
        print(f"Package '{package_name}' not found", file=sys.stderr)
        print(f"Available packages: {', '.join(sorted(available_packages.keys()))}", file=sys.stderr)
        sys.exit(1)
    
    pkg_info = available_packages[package_name]
    print(f"Package type detected: {pkg_info['type']}")
    
    # Check rate limit before starting
    check_rate_limit()
    
    # Update based on package type
    result = None
    
    if pkg_info["type"] == "vimr-binary":
        result = update_vimr(pkg_info["path"])
    elif pkg_info["type"] == "pre-built-binary" and package_name == "sbctl":
        result = update_sbctl(pkg_info["path"])
    elif pkg_info["type"] in ["go-module-simple", "go-module-platform-specific", "github-source"]:
        if pkg_info["owner"] and pkg_info["repo"]:
            result = update_github_source_package(pkg_info)
        else:
            print(f"No GitHub repository information found for {package_name}", file=sys.stderr)
            sys.exit(1)
    else:
        print(f"Package type '{pkg_info['type']}' not yet supported for automatic updates", file=sys.stderr)
        print(f"Supported types: vimr-binary, pre-built-binary, go-module-simple, go-module-platform-specific, github-source")
        sys.exit(1)
    
    # Set default outputs for GitHub Actions if no update was found
    if not result and os.environ.get("GITHUB_ACTIONS"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write("updated=false\n")
    
    print("Package update check completed.")

if __name__ == "__main__":
    main()