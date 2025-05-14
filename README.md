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

4. Install configurations based on your needs:
   - For user configuration only:
     ```bash
     make <username>
     ```
   - For full system configuration:
     ```bash
     make <hostname>
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

1. Create or modify host configurations in `/hosts/<hostname>/`
2. Adjust user configurations in `/users/<username>/`
3. Add custom packages to `/pkgs/`
4. Create overlays in `/overlays/`

See the `flake.nix` file for the main configuration structure.

## License

[MIT License](LICENSE)

Copyright (c) 2024 Chuck D'Antonio
