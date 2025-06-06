{ pkgs, ... }: {
  # Cloud engineering profile with cloud tools and Kubernetes
  imports = [
    ../modules/base.nix
    ../modules/cloud.nix
    ../modules/kubernetes.nix
    ../modules/security.nix
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin ../modules/darwin.nix;
}