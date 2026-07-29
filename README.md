# Chuck's Dotfiles

A [Nix](https://nixos.org)-based system and home configuration management setup for macOS and Linux
environments.

## Overview

This repository contains dotfiles and system configurations managed using
[Nix](https://nixos.org/), [Home
Manager](https://github.com/nix-community/home-manager), and
[nix-darwin](https://github.com/LnL7/nix-darwin). It provides a declarative,
reproducible approach to configuring systems and user environments across
multiple machines.

I've evolved this setup across many years, taking the [Nix](https://nixos.org)-based approach since
early 2024. The earliest iteration was a couple of files, and it's evolved
quite a bit since then. I've used custom shell scripts, adopted a lot from
Pivotal's [workstation setup](https://github.com/pivotal/workstation-setup),
and used [Strap](https://github.com/MikeMcQuaid/strap) by @MikeMcquaid. 

All along, this repo kept evolving but never quite satisfied me. It was too
for configs to drift and to get annoyed something was missing. Once I started
to adopt [Nix](https://nixos.org), I realized I could get closer to the repeatable setup I was
looking for---even if it is probably overkill for one person with a handful of
machines to be so pedantic about keeping things consistent and automated..

Though most of that evolution, I needed to keep things private in spite of how
much I *ahem* borrowed *ahem* from others' shared dotfiles. Once I added
[SOPS](https://github.com/mozilla/sops) support into my [Nix](https://nixos.org) setup, I realized
I could finally start sharing.

## Features

- Complete system configuration via [Nix](https://nixos.org) Flakes
- Support for both macOS (Darwin) and Linux ([Nix](https://nixos.org)OS) systems
- Multiple user profiles with different configurations
- Secret management with sops-nix
- Comprehensive development environment setup
- Automated setup and management via Makefile

## Directory Structure

- `/hosts` - Host-specific configurations for different systems
- `/overlays` - [Nix](https://nixos.org) overlays for package customization
- `/pkgs` - Custom package definitions
- `/users` - User-specific configuration files
- `/files` - Utility scripts and shared files
- `/pki` - Certificate files
- `/work` - Work-specific configurations

## Requirements

- [Nix](https://nixos.org/download.html)
- [Flakes](https://nixos.wiki/wiki/Flakes) enabled
- [Home Manager](https://github.com/nix-community/home-manager) for user environment management
- [nix-darwin](https://github.com/LnL7/nix-darwin) (for macOS systems)

## Installation

### First-time Setup

1. Install [Nix](https://nixos.org):
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Enable flakes by creating or editing `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```

3. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

4. Import the PGP public keys used to encrypt secrets:
   ```bash
   gpg --import .sops.pub.asc
   ```
   See [Secrets](#secrets) for why this is necessary.

5. Install configurations based on your needs:
   - For user configuration only:
     ```bash
     make <username>
     ```
   - For full system configuration:
     ```bash
     make <hostname>
     ```

### Secrets

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) to the PGP
subkeys listed in `.sops.yaml`, and decrypted at activation time by
[sops-nix](https://github.com/Mic92/sops-nix). The private keys live on a
YubiKey; `.sops.pub.asc` is a bundle of the matching **public** keys, covering
every recipient in `.sops.yaml`.

Nothing imports that bundle automatically — SOPS reads `.sops.yaml` for
fingerprints and expects the keys themselves to already be in your GnuPG
keyring. Import it by hand, as above.

It is needed in both directions. Encrypting or running `sops updatekeys`
requires the public key of every recipient. Decrypting requires it too, even
though the YubiKey does the actual work: GnuPG will only drive a card-held
subkey when the corresponding public subkey is present to bind the shadow stub
in `~/.gnupg/private-keys-v1.d/`.

If secrets stop decrypting, that binding is the first thing to check. A working
encryption subkey shows as `ssb>` (card-backed); `ssb#` means the private half
is absent and `gpg --list-keys` failing outright means the public subkey is
missing:

```bash
gpg --list-secret-keys --keyid-format=long   # want ssb> on an [E] subkey
gpg --import .sops.pub.asc && gpg --card-status
```

Note that a bare `sops -d` will fail against a YubiKey regardless. SOPS defaults
to a native Go OpenPGP backend that cannot talk to a smartcard, and reports
`could not decrypt data key with PGP key`. Point it at a real `gpg` to test:

```bash
SOPS_GPG_EXEC=/run/current-system/sw/bin/gpg sops -d home/users/crdant/secrets.yaml
```

Use that path rather than `$(which gpg)`. On macOS, Homebrew's `gpg` comes first
on `PATH` and is newer than the `gpg-agent` this flake runs; a newer client
against an older agent fails to decrypt through the card, with SOPS reporting
`no master key was able to decrypt the file`.

On macOS, sops-nix decrypts from a launchd agent rather than inline during
activation, so its failures do not surface in `make user` output:

```bash
launchctl print gui/$(id -u)/org.nix-community.home.sops-nix | grep 'last exit code'
tail ~/Library/Logs/SopsNix/stderr
```

### Common Commands

Use the Makefile for common operations:

```bash
# Show available configurations
make show

# Apply current user's home configuration
make user

# Apply current host's system configuration
make host

# Update flake inputs
make update

# Check flake validity
make check

# Clean up [Nix](https://nixos.org) store
make clean
```

## Customization

To customize configurations:

1. Create or modify host configurations in `/systems/hosts/<hostname>/`
2. Adjust user configurations in `/home/users/<username>/`
3. Add custom packages to `/pkgs/`
4. Create overlays in `/overlays/`

See the `flake.nix` file for the main configuration structure.

## License

[MIT License](LICENSE)

Copyright (c) 2024 Chuck D'Antonio
