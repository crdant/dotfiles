# Makefile for LLM Plugin Generator
.PHONY: update generate clean check check-all show-supported show-all add-plugin help

# Default target
help:
	@echo "LLM Plugin Generator"
	@echo "==================="
	@echo ""
	@echo "Targets:"
	@echo "  update          - Update plugin versions and generate Nix files"
	@echo "  update-releases - Update using latest releases instead of commits"
	@echo "  generate        - Just regenerate Nix files from existing lock"
	@echo "  clean           - Clean generated files"
	@echo "  check           - Check that all supported plugins build"
	@echo "  check-all       - Check all plugins (including platform-specific)"
	@echo "  show-supported  - Show plugins supported on current platform"
	@echo "  show-all        - Show all plugins in specification"
	@echo "  add-plugin      - Add a new plugin interactively"
	@echo "  help            - Show this help"

# Update plugin versions and generate Nix files
update:
	python3 update-plugins.py --update

# Update using latest releases instead of commits
update-releases:
	python3 update-plugins.py --update --prefer-releases

# Just regenerate Nix files from existing lock
generate:
	python3 update-plugins.py

# Clean generated files
clean:
	rm -f generated-plugins.nix llm-plugins-lock.json overlay.nix

# Check that supported plugins build on current platform
check:
	@echo "Building supported plugins on current platform..."
	@nix-build --no-out-link -A allSupported || echo "Some plugins failed to build"

# Check all plugins (will show which ones are broken/unsupported)
define CHECK_ALL
import json
with open('llm-plugins-lock.json') as f:
    plugins = json.load(f)
for name in plugins:
    print(f'Checking {name}...')
    exit_code = __import__('subprocess').run(['nix-build', '--no-out-link', '-A', name], 
                                            capture_output=True).returncode
    if exit_code == 0:
        print(f'  ✓ {name} builds successfully')
    else:
        print(f'  ✗ {name} failed to build (may be platform-specific)')
endef

check-all:
	@echo "Checking all plugins..."
	@python3 -c "$(CHECK_ALL)"

# Show plugins supported on current platform
show-supported:
	@echo "Plugins supported on current platform:"
	@nix-instantiate --eval --expr 'let pkgs = import <nixpkgs> {}; plugins = pkgs.callPackage ./default.nix {}; in builtins.attrNames plugins.darwinOnly' 2>/dev/null | tr -d '"[],' | tr ' ' '\n' | grep -v '^$$' || true
	@nix-instantiate --eval --expr 'let pkgs = import <nixpkgs> {}; plugins = pkgs.callPackage ./default.nix {}; in builtins.attrNames plugins.linuxOnly' 2>/dev/null | tr -d '"[],' | tr ' ' '\n' | grep -v '^$$' || true

# Show all plugins in specification
define SHOW_ALL
import json
try:
    with open('llm-plugins.json') as f:
        plugins = json.load(f)
    for name, spec in plugins.items():
        platform_info = ''
        if 'platformSpecific' in spec:
            platform_info = f\" (platform-specific: {spec['platformSpecific']})\"
        print(f'  {name}: {spec[\"description\"]}{platform_info}')
except FileNotFoundError:
    print('llm-plugins.json not found')
endef

show-all:
	@echo "All plugins in specification:"
	@python3 -c "$(SHOW_ALL)"

define ADD_PLUGIN
import json
import sys
data = {}
try:
    with open('llm-plugins.json') as f:
        data = json.load(f)
except FileNotFoundError:
    pass
deps_list = [d.strip() for d in '$$deps'.split() if d.strip()]
new_plugin = {
    'owner': '$$owner',
    'repo': '$$repo', 
    'description': '$$desc',
    'pythonDeps': deps_list
}
if '$$platform_specific'.lower().startswith('y'):
    print('Platform configuration needed. Supported platforms:')
    print('1. Darwin only (macOS)')
    print('2. Darwin ARM64 only (Apple Silicon)')
    print('3. Linux only') 
    print('4. Custom (you will edit JSON manually)')
    choice = input('Choose (1-4): ')
    if choice == '1':
        new_plugin['platformSpecific'] = {'darwin': True}
    elif choice == '2':
        new_plugin['platformSpecific'] = {'darwin': {'aarch64': True}}
    elif choice == '3':
        new_plugin['platformSpecific'] = {'linux': True}
    else:
        new_plugin['platformSpecific'] = {'custom': 'edit manually'}
data['$$name'] = new_plugin
with open('llm-plugins.json', 'w') as f:
    json.dump(data, f, indent=2, sort_keys=True)
print(f'Added $$name to llm-plugins.json')
endef

# Add a new plugin interactively
add-plugin:
	@echo "Adding new plugin..."
	@echo "Note: Plugin must be compatible with the LLM plugin system"
	@read -p "Plugin name (e.g., llm-foo): " name; \
	read -p "GitHub owner: " owner; \
	read -p "GitHub repo: " repo; \
	read -p "Description: " desc; \
	echo "Python dependencies (space-separated, press enter for none):"; \
	read deps; \
	echo "Platform specific? (y/N):"; \
	read platform_specific; \
	python3 -c "$(ADD_PLUGIN)"
	@echo "Plugin added! Run 'make update' to fetch and generate."

# Development helpers
dev-shell:
	nix-shell -p python3 python3Packages.requests python3Packages.pip nix-prefetch-git

# Show lock file status
define STATUS
import json
with open('llm-plugins-lock.json') as f:
    data = json.load(f)
for name, info in data.items():
    print(f'  {name}: {info[\"version\"]} ({info[\"short_date\"]})')
endef
status:
	@if [ -f llm-plugins-lock.json ]; then \
		echo "Lock file exists. Last modified:"; \
		stat -c %y llm-plugins-lock.json 2>/dev/null || stat -f %Sm llm-plugins-lock.json; \
		echo ""; \
		echo "Plugins in lock file:"; \
		python3 -c "$(STATUS)"; 
	else \
		echo "No lock file found. Run 'make update' first."; \
	fi
