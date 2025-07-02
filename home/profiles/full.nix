{ pkgs, ... }: {
  # Full workstation profile with all modules
  imports = [
    ../modules/base
    ../modules/desktop
    ../modules/development
    ../modules/editor
    ../modules/go
    ../modules/python
    ../modules/javascript
    ../modules/swift
    ../modules/rust
    ../modules/ai
    ../modules/data
    ../modules/containers
    ../modules/cicd
    ../modules/kubernetes
    ../modules/replicated
    ../modules/security
    ../modules/certificates
    ../modules/aws
    ../modules/google
    ../modules/azure
    ../modules/infrastructure
    ../modules/home-network
    ../modules/homelab
  ];
}
