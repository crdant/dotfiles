{ pkgs, lib, ... }: {
  # Development profile with coding tools and environments
  imports = [
    ../modules/base
    ../modules/development
    ../modules/cloud
    ../modules/kubernetes
    ../modules/ai
    ../modules/security
  ] ;
}
