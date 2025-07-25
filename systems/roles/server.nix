
{ ... }: {
  # Container/CI profile - minimal system with shell access and networking
  # Use case: CI runners, build containers, basic automation
  # Size: ~50 lines of configuration
  
  imports = [
    ../modules/nix-core
    ../modules/hardening
    ../modules/base
    ../modules/shells
    ../modules/networking-tools
    ../modules/home-lab
  ];

  systems.hardening.enable = true;
}
