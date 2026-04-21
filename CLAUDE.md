# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Nix flake-based dotfiles for Chuck D'Antonio's macOS (`nix-darwin`) and Linux (NixOS) machines, plus per-user `home-manager` configurations. Secrets are managed with `sops-nix` (PGP). There is no application code here — all source is Nix, plus a few Python/shell helpers for CI-driven package updates.

## Common commands

The `Makefile` dynamically generates targets by calling `nix eval` on the flake at load time, so `make help` / `make show` are the source of truth for what's currently buildable.

```bash
# Discover available targets (reads flake outputs)
make help
make show

# Apply the current user's home-manager config (uses $(whoami))
make user                      # alias for switch → switch-home-<user>@<current-system>
make build                     # build without switching
make check-home-<user>         # home-manager check

# Apply a specific user/profile combination
make switch-home-<user>                    # resolves to <user>@<arch-os>
make switch-home-<user>:development        # non-"full" profile uses <user>:<profile>@<arch-os>

# Apply the current host's system config (Darwin or NixOS, picked by hostname -s)
make host                      # build + switch for the current hostname
make switch-nixos-<host>       # sudo nixos-rebuild switch --flake .#<host>
make switch-darwin-<host>      # sudo ./result/sw/bin/darwin-rebuild switch --flake . --impure

# Flake maintenance
make update                    # nix flake update
make check                     # nix flake check
make clean                     # nix-collect-garbage -d
```

Home-manager commands pass `--impure` because `chuck.nix`/`darwin.nix` use `builtins.fetchurl` against GitHub and hostname-conditional activation scripts. Darwin builds also use `--impure`.

### Testing custom packages (pkgs/)

Custom packages are not exposed as flake `packages`; they are wired in only through the `additions` overlay. To build or test a single custom package outside home/system activation, use the same pattern the CI test script uses (see `.github/scripts/test-package.sh`):

```bash
nix build --impure --expr \
  'let pkgs = import <nixpkgs> { overlays = [(import ./overlays { inputs = {}; }).additions]; }; in pkgs.<pkgname>' \
  --no-link

# Or the packaged CI helper:
./.github/scripts/test-package.sh <pkgname>     # currently supports vimr, replicated, kots, sbctl
```

Note the overlay package name differs from the directory for one package: `pkgs/sbctl/` → `troubleshoot-sbctl`.

## Architecture

### Flake outputs

`flake.nix` exposes three kinds of configurations:

- **`nixosConfigurations`** — one entry per Linux host under `systems/hosts/<host>/default.nix`. Currently: `mash`.
- **`darwinConfigurations`** — one entry per macOS host. Currently: `aguardiente`, `grappa`, `sochu`, `pisco`.
- **`homeConfigurations`** — *generated* by `generateConfigs` as the cartesian product of `userConfigs × profiles × supportedSystems`. Names follow `user@<arch-os>` for the `full` profile and `user:<profile>@<arch-os>` otherwise (e.g. `crdant@aarch64-darwin`, `crdant:development@x86_64-linux`).

Supported systems: `aarch64-darwin`, `x86_64-linux`. Each home config is built via `mkHomeConfig`, which threads `username`, `homeDirectory`, `gitEmail`, and `profile` through `extraSpecialArgs` so every module can read them.

### Two parallel module trees

This repo has **two independent module hierarchies** that are often confused:

1. **`home/`** — home-manager modules (per-user), composed as:
   `home/modules/<topic>/` → `home/profiles/<profile>.nix` → `home/users/<user>/home.nix` → flake `homeConfigurations`.
   `home/users/<user>/home.nix` imports `../../profiles/${profile}.nix`, and the profile imports the topic modules it wants.

2. **`systems/`** — NixOS/nix-darwin modules (per-host), composed as:
   `systems/modules/<topic>/` → `systems/roles/<role>.nix` → `systems/hosts/<host>/default.nix` → flake `nixosConfigurations` / `darwinConfigurations`.

System host entries in `flake.nix` additionally import the relevant `home/users/<user>/<user>.nix` (e.g. `crdant.nix`) to declare the OS-level user account — this is separate from the home-manager configuration and is what defines `users.users.<name>` on NixOS/Darwin. On Darwin hosts they also import `home/users/crdant/darwin.nix` for host-level Homebrew/macOS defaults.

### Profiles

`home/profiles/` defines four profiles that gate which topic modules load:

- `minimal` — only `base`
- `server` — `base`, `secrets`, `security`, `editor`, `homelab`
- `development` — development-heavy stack (no `desktop`, no `replicated`, no `obsidian`)
- `full` — everything in `development` plus `desktop`, `replicated`, `home-network`, `obsidian`

`home/users/crdant/README.md` documents a broader matrix but some profiles it describes (`basic`, `ai`, `cloud`) don't exist as files — treat the actual `home/profiles/*.nix` as authoritative.

### User variants for the same human

`crdant.nix` and `chuck.nix` under `home/users/crdant/` both belong to Chuck but select different `gitEmail` values (`chuck@crdant.io` vs `chuck@replicated.com`). The `sochu` Darwin host uses `chuck.nix` — that's the work machine, and `home/modules/ai/default.nix` contains a hostname-conditional block (`if [ "$(/bin/hostname -s)" = "sochu" ]`) that copies Replicated-installed Claude agents/commands into the `replicated` config directory. Be careful when editing the AI module: `$CLAUDE_CONFIG_DIR` is selected at shell init time by username (`chuck` → `replicated`, otherwise → `personal`).

### Overlays and custom packages

`overlays/default.nix` exports four named overlays, all wired in by both `home/modules/base/default.nix` and `systems/modules/nix-core/default.nix`:

- `additions` — exposes everything in `pkgs/` via `pkgs.callPackage`.
- `modifications` — version pins (e.g. `container`), `vimPlugins` additions (`nvim-aider`), and `python3Packages` additions (`exa-py`, `mlx-lm`).
- `unstable-packages` — makes `pkgs.unstable.*` resolve against `nixpkgs-unstable`.
- `nur-packages` — makes `pkgs.nur.*` resolve.

When adding a package to `pkgs/`, also add a `callPackage` line in `pkgs/default.nix`; the `additions` overlay re-exports the whole attrset.

### Secrets (sops-nix)

`.sops.yaml` defines creation rules for two locations:

- `secrets/*.{yaml,json,env,ini}` — git-ignored at the tree level (see `.gitignore`); only `*.enc` files are checked in.
- `home/users/crdant/secrets.yaml` — checked in, encrypted.

`home/users/crdant/home.nix` sets `_module.args.secretsFile = ./secrets.yaml`, which the `home/modules/secrets` module consumes via `secretsFile ? null`. Other users don't have a `secrets.yaml`, so their `secretsFile` is `null` and sops is effectively skipped — keep this guard if adding secret consumers.

The AI module is the primary secrets consumer: `home/modules/ai/default.nix` uses `config.sops.templates.*` to render `.aider.conf.yml`, `crush.json`, `goose/config.yaml`, and `mcp-servers.json` with API keys pulled from the encrypted store. `home/modules/ai/config/mcp.nix` is the single source of truth for MCP server definitions; it's imported both into the `crush.json` template and into the standalone `mcp-servers.json` file.

### Claude Code plugin management

`home/modules/ai/default.nix` defines a **repo-local** option `programs.claude.plugins` (type `listOf str`, format `<plugin>@<marketplace>`). Any home module can append to it — e.g. `home/modules/development/default.nix` adds `compound-engineering@compound-engineering-plugin`. The `claudePlugins` activation script registers each marketplace declared in the `marketplaces` attrset, then idempotently runs `claude plugin install` for every entry in the merged list. Marketplaces are centralized in the AI module because `attrsOf str` doesn't merge duplicate keys.

Plugin removal is **not** declarative — removing an entry from config does not uninstall it from disk.

## CI package updates

`.github/workflows/` contains per-package "update" workflows (`update-vimr.yml`, `update-replicated.yml`, `update-kots.yml`, `update-sbctl.yml`) fanned out from `update-all-packages.yml`. They rely on:

- `.github/scripts/update-package.py` — fetches latest GitHub releases, updates `version` + `sha256` in `pkgs/<name>/default.nix`.
- `.github/scripts/calculate-go-vendor-hash.py` — recomputes `vendorHash` for Go modules (Darwin and Linux hashes both need updating; see `pkgs/replicated/default.nix` for the `isDarwin` conditional pattern).
- `.github/scripts/test-package.sh` — builds and smoke-tests the resulting package.

When adding an auto-updated package, follow the existing package-name mapping in `test-package.sh` if the attribute name differs from the directory name.

## Conventions

- The `work/` directory is git-ignored (except `.gitkeep`) and used for scratch files via `$WORK_DIR` from `.envrc`.
- `docs/plans/` and `docs/research/` hold dated planning/research artifacts (`YYYY-MM-DD-<slug>.md`). `thoughts/shared/` mirrors this layout for cross-machine notes. Consider adding new plans/research here rather than scattered through the tree.
- `direnv` is configured via `.envrc`; sourcing it sets `$PROJECT_DIR`, `$SECRETS_DIR`, `$WORK_DIR`, and prepends `./bin` to `PATH`.
- Pull request bodies follow the "TL;DR / Details" template in `.github/pull_request_template.md`: declarative present tense ("Adds…", "Replaces…"), explain *why* and what conventions were followed, skip what's obvious from the diff.
- All home-manager modules receive `username`, `homeDirectory`, `gitEmail`, and `profile` via `extraSpecialArgs` — use these rather than hardcoding.
- Use `lib.optionals isDarwin` / `lib.optionals isLinux` for platform-specific package lists, and `lib.optionalAttrs` for platform-specific attrset merges (this pattern is used throughout).
