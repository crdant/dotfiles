# Dynamic Makefile for Nix configurations using nix eval

# Configuration variables
SHELL := /bin/bash
FLAKE_PATH := .
NIX := nix

# Extract configuration names using nix eval
NIXOS_SYSTEMS := $(shell $(NIX) eval --impure --json $(FLAKE_PATH)#nixosConfigurations --apply 'builtins.attrNames' 2>/dev/null | tr -d '[]"' | tr ',' ' ' || echo "")
DARWIN_SYSTEMS := $(shell $(NIX) eval --impure --json $(FLAKE_PATH)#darwinConfigurations --apply 'builtins.attrNames' 2>/dev/null | tr -d '[]"' | tr ',' ' ' || echo "")
HOME_CONFIGS := $(shell $(NIX) eval --impure --json $(FLAKE_PATH)#homeConfigurations --apply 'builtins.attrNames' 2>/dev/null | tr -d '[]"' | tr ',' ' ' || echo "")

.PHONY: help
help: ## Show this help menu
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "NixOS Systems: $(NIXOS_SYSTEMS)"
	@echo "Darwin Systems: $(DARWIN_SYSTEMS)"
	@echo "Home Configurations: $(HOME_CONFIGS)"

.PHONY: show
show: ## Show available configurations in the flake
	@echo "NixOS Systems:"
	@for system in $(NIXOS_SYSTEMS); do echo "  $$system"; done
	@echo "Darwin Systems:"
	@for system in $(DARWIN_SYSTEMS); do echo "  $$system"; done
	@echo "Home Configurations:"
	@for config in $(HOME_CONFIGS); do echo "  $$config"; done

.PHONY: update
update: ## Update flake inputs
	$(NIX) flake update 

.PHONY: check
check: ## Check flake
	$(NIX) flake check 

# Generate targets for NixOS systems
define nixos_system_targets
.PHONY: build-nixos-$(1)
build-nixos-$(1): ## Build NixOS configuration for $(1)
	$(NIX) build $(FLAKE_PATH)#nixosConfigurations.$(1).config.system.build.toplevel

.PHONY: switch-nixos-$(1)
switch-nixos-$(1): ## Switch to NixOS configuration for $(1)
	sudo nixos-rebuild switch --flake $(FLAKE_PATH)#$(1)

.PHONY: boot-nixos-$(1)
boot-nixos-$(1): ## Build NixOS configuration for $(1) and add it to the boot menu
	sudo nixos-rebuild boot --flake $(FLAKE_PATH)#$(1)

.PHONY: test-nixos-$(1)
test-nixos-$(1): ## Test NixOS configuration for $(1) without adding it to the boot menu
	sudo nixos-rebuild test --flake $(FLAKE_PATH)#$(1)

$(1): build-nixos-$(1) switch-nixos-$(1)
endef

$(foreach system,$(NIXOS_SYSTEMS),$(eval $(call nixos_system_targets,$(system))))

# Generate targets for Darwin systems
define darwin_system_targets
.PHONY: build-darwin-$(1)
build-darwin-$(1): ## Build Darwin configuration for $(1)
	$(NIX) build $(FLAKE_PATH)#darwinConfigurations.$(1).system --impure

.PHONY: switch-darwin-$(1)
switch-darwin-$(1): ## Switch to Darwin configuration for $(1)
	./result/sw/bin/darwin-rebuild switch --flake $(FLAKE_PATH) --impure

$(1): build-darwin-$(1) switch-darwin-$(1)
endef

$(foreach system,$(DARWIN_SYSTEMS),$(eval $(call darwin_system_targets,$(system))))

# Generate targets for home-manager configurations
define home_config_targets
.PHONY: build-home-$(1)
build-home-$(1): ## Build home-manager configuration for $(1)
	home-manager build --flake $(FLAKE_PATH)#$(1) --impure

.PHONY: switch-home-$(1)
switch-home-$(1): ## Switch to home-manager configuration for $(1)
	home-manager switch --flake $(FLAKE_PATH)#$(1) --impure --show-trace

.PHONY: check-home-$(1)
check-home-$(1): ## Check home-manager configuration for $(1)
	home-manager check -b --flake $(FLAKE_PATH)#$(1) --impure

$(1): build-home-$(1) switch-home-$(1)
endef

$(foreach config,$(HOME_CONFIGS),$(eval $(call home_config_targets,$(config))))

# Convenience targets for the current user
CURRENT_USER := $(shell whoami)

.PHONY: build
build: build-home-$(CURRENT_USER) ## Build home-manager configuration for current user

.PHONY: switch
switch: switch-home-$(CURRENT_USER) ## Switch to home-manager configuration for current user

user: build switch
$(CURRENT_USER): build switch
 
# Host-specific targets
HOSTNAME := $(shell hostname -s)

.PHONY: build-host
build-host: ## Switch configuration for current host
	@if echo "$(DARWIN_SYSTEMS)" | grep -q $(HOSTNAME); then \
		$(MAKE) build-darwin-$(HOSTNAME); \
	elif echo "$(NIXOS_SYSTEMS)" | grep -q $(HOSTNAME); then \
		$(MAKE) build-nixos-$(HOSTNAME); \
	else \
		echo "No system configuration found for host $(HOSTNAME)"; \
		exit 1; \
	fi

.PHONY: switch-host
switch-host: ## Switch configuration for current host
	@if echo "$(DARWIN_SYSTEMS)" | grep -q $(HOSTNAME); then \
		$(MAKE) switch-darwin-$(HOSTNAME); \
	elif echo "$(NIXOS_SYSTEMS)" | grep -q $(HOSTNAME); then \
		$(MAKE) switch-nixos-$(HOSTNAME); \
	else \
		echo "No system configuration found for host $(HOSTNAME)"; \
		exit 1; \
	fi

host: build-host switch-host
$(HOSTNAME): build-host switch-host

# Cleanup and maintenance
.PHONY: clean
clean: ## Clean nix store
	nix-collect-garbage -d

.PHONY: clean-old-generations
clean-old-generations: ## Clean old generations
	nix-collect-garbage -d
	sudo nix-collect-garbage -d

.PHONY: gc
gc: ## Garbage collect
	$(NIX) store gc

# When you have implemented profile configurations, add this:
# .PHONY: list-profiles
# list-profiles: ## List available home configuration profiles
# 	@$(NIX) eval --impure --json $(FLAKE_PATH)#homeProfileConfigurations --apply 'confs: builtins.map (name: builtins.elemAt (builtins.split "-" name) 1) (builtins.attrNames confs)' 2>/dev/null | sort -u | tr -d '[]"' | tr ',' '\n' | sed 's/^ */  /'
