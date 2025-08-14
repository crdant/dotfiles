{ pkgs, ... }: {
  # Embedded/IoT profile - absolute minimum for Nix functionality
  # Use case: IoT devices, embedded systems, minimal containers
  # Size: ~20 lines of configuration
  
  imports = [
    ./server.nix
    ../modules/dns
  ];

}

