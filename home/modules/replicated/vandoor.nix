{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {

  # Kubernetes and container-related packages
  home = {
    packages = with pkgs; [
      gpgme
      okteto
      pkg-config
    ];
  };  
}

