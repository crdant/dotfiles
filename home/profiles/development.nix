{ pkgs, lib, ... }: {
  # Development profile with coding tools and environments
  imports = [
    ../modules/base
    ../modules/development
    ../modules/editor
    ../modules/go
    ../modules/python
    ../modules/javascript
    ../modules/swift
    ../modules/rust
    ../modules/data
    ../modules/containers
    ../modules/cicd
    ../modules/aws
    ../modules/google
    ../modules/azure
    ../modules/infrastructure
    ../modules/kubernetes
    ../modules/ai
    ../modules/claude
    ../modules/opencode
    ../modules/codex
    ../modules/secrets
    ../modules/security
    ../modules/certificates
  ] ;
}
