#!/usr/bin/env python3
# update-plugins.py

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, Any, Optional
import requests
from datetime import datetime

def get_latest_commit_info(owner: str, repo: str) -> Dict[str, str]:
    """Fetch latest commit info from GitHub API."""
    url = f"https://api.github.com/repos/{owner}/{repo}/commits/HEAD"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        commit_data = response.json()
        
        rev = commit_data["sha"]
        commit_date = commit_data["commit"]["committer"]["date"]
        
        # Use nix-prefetch-git to get the sha256
        result = subprocess.run([
            "nix-prefetch-git", 
            "--url", f"https://github.com/{owner}/{repo}",
            "--rev", rev,
            "--quiet"
        ], capture_output=True, text=True, check=True)
        
        prefetch_data = json.loads(result.stdout)
        
        return {
            "rev": rev,
            "sha256": prefetch_data["sha256"],
            "date": commit_date,
            "short_date": commit_date[:10]  # YYYY-MM-DD
        }
        
    except (requests.RequestException, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        print(f"Error fetching info for {owner}/{repo}: {e}", file=sys.stderr)
        return {
            "rev": "main",
            "sha256": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            "date": "1970-01-01T00:00:00Z",
            "short_date": "1970-01-01"
        }

def get_latest_release_info(owner: str, repo: str) -> Optional[Dict[str, str]]:
    """Fetch latest release info from GitHub API."""
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    
    try:
        response = requests.get(url)
        if response.status_code == 404:
            return None  # No releases
        response.raise_for_status()
        release_data = response.json()
        
        tag_name = release_data["tag_name"]
        # Clean up version tags (remove 'v' prefix if present)
        version = tag_name.lstrip('v')
        
        # Use nix-prefetch-git to get the sha256 for the tag
        result = subprocess.run([
            "nix-prefetch-git", 
            "--url", f"https://github.com/{owner}/{repo}",
            "--rev", tag_name,
            "--quiet"
        ], capture_output=True, text=True, check=True)
        
        prefetch_data = json.loads(result.stdout)
        
        return {
            "version": version,
            "rev": tag_name,
            "sha256": prefetch_data["sha256"],
            "date": release_data["published_at"],
            "short_date": release_data["published_at"][:10]
        }
        
    except (requests.RequestException, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        print(f"Warning: Could not fetch release info for {owner}/{repo}: {e}", file=sys.stderr)
        return None

def load_plugin_specs(spec_file: Path) -> Dict[str, Any]:
    """Load plugin specifications from JSON file."""
    with spec_file.open() as f:
        return json.load(f)

def update_plugin_lock(spec_file: Path, lock_file: Path, prefer_releases: bool = True) -> None:
    """Update the lock file with latest commit/release information."""
    specs = load_plugin_specs(spec_file)
    
    print("Updating plugin lock file...")
    lock_data = {}
    
    for name, spec in specs.items():
        print(f"  Fetching {name}...")
        
        # Try to get release info first if preferred
        version_info = None
        if prefer_releases:
            version_info = get_latest_release_info(spec["owner"], spec["repo"])
        
        # Fall back to latest commit if no release or not preferred
        if not version_info:
            commit_info = get_latest_commit_info(spec["owner"], spec["repo"])
            version_info = {
                "version": f"unstable-{commit_info['short_date']}",
                **commit_info
            }
        
        lock_data[name] = {
            **spec,
            **version_info
        }
    
    with lock_file.open('w') as f:
        json.dump(lock_data, f, indent=2, sort_keys=True)
    
    print(f"Updated {len(lock_data)} plugins in {lock_file}")

def format_platform_condition(platform_spec: Dict[str, Any]) -> str:
    """Format platform-specific conditions for Nix."""
    conditions = []
    
    if "darwin" in platform_spec:
        darwin_spec = platform_spec["darwin"]
        if isinstance(darwin_spec, dict):
            if "aarch64" in darwin_spec:
                if darwin_spec["aarch64"]:
                    conditions.append("stdenv.isDarwin && stdenv.isAarch64")
                else:
                    conditions.append("stdenv.isDarwin && !stdenv.isAarch64")
            elif "x86_64" in darwin_spec:
                if darwin_spec["x86_64"]:
                    conditions.append("stdenv.isDarwin && stdenv.isx86_64")
                else:
                    conditions.append("stdenv.isDarwin && !stdenv.isx86_64")
            else:
                conditions.append("stdenv.isDarwin")
    
    if "linux" in platform_spec:
        linux_spec = platform_spec["linux"]
        if isinstance(linux_spec, dict):
            if "aarch64" in linux_spec:
                if linux_spec["aarch64"]:
                    conditions.append("stdenv.isLinux && stdenv.isAarch64")
                else:
                    conditions.append("stdenv.isLinux && !stdenv.isAarch64")
            elif "x86_64" in linux_spec:
                if linux_spec["x86_64"]:
                    conditions.append("stdenv.isLinux && stdenv.isx86_64")
                else:
                    conditions.append("stdenv.isLinux && !stdenv.isx86_64")
            else:
                conditions.append("stdenv.isLinux")
    
    return " || ".join(conditions) if conditions else "true"

def generate_nix_file(lock_file: Path, output_file: Path) -> None:
    """Generate the Nix file from lock data."""
    with lock_file.open() as f:
        lock_data = json.load(f)
    
    # Generate Nix code
    nix_content = '''# This file is generated automatically. Do not edit manually.
# Update with: python3 update-plugins.py

{ lib, callPackage, fetchFromGitHub, python3Packages, stdenv }:

let
  buildLlmPlugin = callPackage ./build-llm-plugin.nix {};
in
{
'''
    
    for name, data in sorted(lock_data.items()):
        python_deps = data.get("pythonDeps", [])
        python_deps_nix = "[" + " ".join(f'"{dep}"' for dep in python_deps) + "]"
        
        platform_specific = data.get("platformSpecific", {})
        platform_nix = "{}" if not platform_specific else "{\n" + "".join(
            f'    {key} = {json.dumps(value).lower()};\n' 
            for key, value in platform_specific.items()
        ) + "  }"
        
        nix_content += f'''  {name} = buildLlmPlugin {{
    pname = "{name}";
    version = "{data["version"]}";
    src = fetchFromGitHub {{
      owner = "{data["owner"]}";
      repo = "{data["repo"]}";
      rev = "{data["rev"]}";
      sha256 = "{data["sha256"]}";
    }};
    description = "{data["description"]}";
    pythonDeps = {python_deps_nix};'''
        
        if platform_specific:
            nix_content += f'\n    platformSpecific = {platform_nix};'
        
        nix_content += '\n  };\n\n'
    
    nix_content += "}\n"
    
    with output_file.open('w') as f:
        f.write(nix_content)
    
    print(f"Generated {output_file}")

def generate_convenience_overlay(lock_file: Path, overlay_file: Path) -> None:
    """Generate a convenience overlay file for easy integration."""
    with lock_file.open() as f:
        lock_data = json.load(f)
    
    plugin_names = list(lock_data.keys())
    
    overlay_content = f'''# Generated LLM plugins overlay
# This overlay provides all LLM plugins as top-level packages

final: prev: {{
  llmPlugins = final.callPackage ./generated-plugins.nix {{}};
  
  # Individual plugins available at top level
''' + '\n'.join(f'  {name} = final.llmPlugins.{name};' for name in plugin_names) + '''

  # Convenience function to create LLM with selected plugins
  llmWithPlugins = pluginList: 
    let
      pythonEnv = final.python3.withPackages (ps: [ ps.llm ] ++ pluginList);
    in final.writeShellScriptBin "llm" \'\'
      exec ${{pythonEnv}}/bin/llm "$@"
    \'\';
}}
'''
    
    with overlay_file.open('w') as f:
        f.write(overlay_content)
    
    print(f"Generated convenience overlay: {overlay_file}")

def main():
    script_dir = Path(__file__).parent
    spec_file = script_dir / "llm-plugins.json"
    lock_file = script_dir / "llm-plugins-lock.json"
    output_file = script_dir / "generated-plugins.nix"
    overlay_file = script_dir / "overlay.nix"
    
    prefer_releases = "--prefer-releases" in sys.argv
    
    if len(sys.argv) > 1 and (sys.argv[1] == "--update" or "--update" in sys.argv):
        update_plugin_lock(spec_file, lock_file, prefer_releases)
    
    if lock_file.exists():
        generate_nix_file(lock_file, output_file)
        generate_convenience_overlay(lock_file, overlay_file)
    else:
        print(f"Lock file {lock_file} doesn't exist. Run with --update first.")
        sys.exit(1)

if __name__ == "__main__":
    main()