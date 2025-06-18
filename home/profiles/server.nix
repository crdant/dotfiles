{ pkgs, ... }: {
  # AI-focused profile for working with AI tools and assistants
  imports = [
    ../modules/base.nix
    ../modules/security.nix
  ] ;
}
