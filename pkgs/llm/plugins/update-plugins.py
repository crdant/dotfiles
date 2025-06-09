#!/usr/bin/env python3
# update-plugins.py

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, Any, Optional
import requests
from datetime import datetime

def get_ref_info(owner: str, repo: str, ref: str) -> Dict[str, str]:
    """Fetch commit info for a specific ref from GitHub API."""
    url = f"https://api.github.com/repos/{owner}/{repo}/commits/{ref}"
    
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
            "--rev", ref,
            "--quiet"
        ], capture_output=True, text=True, check=True)
        
        prefetch_data = json.loads(result.stdout)
        
        # Convert hash to SRI format
        convert_result = subprocess.run([
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri",
            prefetch_data["sha256"]
        ], capture_output=True, text=True, check=True)
        
        sri_hash = convert_result.stdout.strip()
        
        return {
            "rev": ref,
            "sha256": sri_hash,
            "date": commit_date,
            "short_date": commit_date[:10]  # YYYY-MM-DD
        }
        
    except (requests.RequestException, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        print(f"Error fetching info for {owner}/{repo}@{ref}: {e}", file=sys.stderr)
        return {
            "rev": ref,
            "sha256": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            "date": "1970-01-01T00:00:00Z",
            "short_date": "1970-01-01"
        }


def load_plugin_specs(spec_file: Path) -> Dict[str, Any]:
    """Load plugin specifications from JSON file."""
    with spec_file.open() as f:
        return json.load(f)

def update_plugin_lock(spec_file: Path, lock_file: Path) -> None:
    """Update the lock file with commit information for specified refs."""
    specs = load_plugin_specs(spec_file)
    
    print("Updating plugin lock file...")
    lock_data = {}
    
    for name, spec in specs.items():
        ref = spec["ref"]
        print(f"  Fetching {name}@{ref}...")
        
        # Get info for the specific ref
        ref_info = get_ref_info(spec["owner"], spec["repo"], ref)
        
        # Determine version based on ref type
        if ref.startswith("v") and ref[1:].replace(".", "").replace("-", "").isalnum():
            # Looks like a version tag
            version = ref.lstrip("v")
        elif ref in ["main", "master", "HEAD"] or len(ref) == 40:  # branch or commit hash
            version = f"unstable-{ref_info['short_date']}"
        else:
            # Custom ref (could be branch, tag, etc.)
            version = f"ref-{ref}"
        
        lock_data[name] = {
            **spec,
            "version": version,
            **ref_info
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

def format_nix_value(value):
    """Convert Python values to Nix syntax."""
    if isinstance(value, bool):
        return "true" if value else "false"
    elif isinstance(value, str):
        return f'"{value}"'
    elif isinstance(value, dict):
        items = []
        for k, v in value.items():
            # Use quoted keys if they contain special characters, otherwise unquoted
            if k.isidentifier():
                key_str = k
            else:
                key_str = f'"{k}"'
            items.append(f"{key_str} = {format_nix_value(v)};")
        return "{\n" + "".join(f"    {item}\n" for item in items) + "  }"
    elif isinstance(value, list):
        return "[" + " ".join(format_nix_value(item) for item in value) + "]"
    else:
        return str(value)

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
            platform_nix = format_nix_value(platform_specific)
            nix_content += f'\n    platformSpecific = {platform_nix};'
        
        nix_content += '\n  };\n\n'
    
    nix_content += "}\n"
    
    with output_file.open('w') as f:
        f.write(nix_content)
    
    print(f"Generated {output_file}")

def main():
    script_dir = Path(__file__).parent
    spec_file = script_dir / "llm-plugins.json"
    lock_file = script_dir / "llm-plugins-lock.json"
    output_file = script_dir / "generated-plugins.nix"
    
    if len(sys.argv) > 1 and (sys.argv[1] == "--update" or "--update" in sys.argv):
        update_plugin_lock(spec_file, lock_file)
    
    if lock_file.exists():
        generate_nix_file(lock_file, output_file)
    else:
        print(f"Lock file {lock_file} doesn't exist. Run with --update first.")
        sys.exit(1)

if __name__ == "__main__":
    main()
