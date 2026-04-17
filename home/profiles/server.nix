{ pkgs, ... }: {
  # AI-focused profile for a home environment on a remote server
  imports = [
    ../modules/base
    ../modules/secrets
    ../modules/security
    ../modules/editor
    ../modules/homelab
  ] ;
}
