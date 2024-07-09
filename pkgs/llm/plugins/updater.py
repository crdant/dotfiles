import json
import urllib.request
import urllib.error
import ssl
from urllib.parse import urljoin
import json
from functools import cmp_to_key
import subprocess

import re

def version_compare(v1, v2):
    def parse(v):
        # Split version string into numeric and non-numeric parts
        return [int(x) if x.isdigit() else x for x in re.findall(r'\d+|\D+', v)]
    
    parts1 = parse(v1)
    parts2 = parse(v2)
    
    for p1, p2 in zip(parts1, parts2):
        if isinstance(p1, int) and isinstance(p2, int):
            if p1 != p2:
                return p2 - p1
        elif p1 != p2:
            # If parts are not both integers, compare them as strings
            return -1 if p1 < p2 else 1
    
    # If all parts are equal so far, longer version is considered newer
    return len(parts2) - len(parts1)

def fetch_pypi_info(package_name):
    url = f"https://pypi.org/pypi/{package_name}/json"
    try:
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(url, context=context) as response:
            data = json.loads(response.read())
            releases = data['releases']
            versions = sorted(releases.keys(), key=cmp_to_key(version_compare), reverse=True)
            latest_version = versions[0]
            
            sdist_url = next((url['url'] for url in data['releases'][latest_version] if url['packagetype'] == 'sdist'), None)
            
            if sdist_url:
                try:
                    result = subprocess.run(['nix-prefetch-url', '--unpack', sdist_url], capture_output=True, text=True, check=True)
                    sha256 = result.stdout.strip()
                except subprocess.CalledProcessError as e:
                    print(f"Error fetching SHA256 for {package_name}: {e}")
                    sha256 = None
            else:
                print(f"No source distribution found for {package_name}")
                sha256 = None

            
            return {
                "name": package_name,
                "version": latest_version,
                "sdist_url": sdist_url,
                "description": data['info']['summary'],
                "dependencies": data['info']['requires_dist'],
                "homepage": data['info']['project_urls'].get('Homepage', data['info']['home_page']),
                "license": data['info']['license'] or "UNKNOWN",
                "sha256": sha256
            }
    except urllib.error.HTTPError as e:
        print(f"Error fetching info for {package_name}: HTTP {e.code}")
        return None
    except Exception as e:
        print(f"Error fetching info for {package_name}: {str(e)}")
        return None

def generate_nix_expression(plugins_info):
    nix_exprs = []
    for plugin in plugins_info:
        if plugin and plugin['sha256']:
            # Strip "llm-" prefix from the name
            stripped_name = plugin["name"].removeprefix("llm-")
            # Parse dependencies from requires_dist
            
            # Generate the propagatedBuildInputs string
            package_dependencies = f"python3Packages.{dep}" for dep in parse_dependencies(plugin["dependencies"]])
            build_inputs = " ".join(package_dependencies +  "llm")
            nix_expr = f'''
  {stripped_name} = buildPythonPackage rec {{
    pname = "{stripped_name}";
    version = "{plugin["version"]}";
    pyproject = true;

    src = fetchzip {{
      url = "{plugin["sdist_url"]}";
      sha256 = "{plugin["sha256"]}";
    }};

    doCheck = false;
    propagatedBuildInputs = [ {build_inputs} ];

    meta = with lib; {{
      description = "{plugin["description"]}";
      homepage = "{plugin["homepage"]}";
    }};
  }};
'''
            nix_exprs.append(nix_expr)
        else:
            print(f"Skipping {plugin['name']} due to missing information")

    return "{\n" + "\n".join(nix_exprs) + "\n}"

if __name__ == "__main__":
    with open("plugins.json", "r") as f:
        plugins = json.load(f)
    
    plugins_info = [fetch_pypi_info(plugin) for plugin in plugins]
    plugins_info = [p for p in plugins_info if p]  # Remove None values
    
    nix_output = generate_nix_expression(plugins_info)
    
    with open("generated.nix", "w") as f:
        f.write("{ lib, buildPythonPackage, fetchzip, llm }:\n")
        f.write(nix_output)

    print(f"Generated Nix expressions for {len(plugins_info)} plugins")
