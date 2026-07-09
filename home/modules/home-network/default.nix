{ inputs, outputs, options, config, pkgs, lib, ... }:

{
  # Homelab-specific SSH configurations
  programs = {
    ssh = {
      settings = {
        "exit.crdant.net" = {
          HostName = "exit.crdant.net";
          User = "arceus";
          IdentityFile = "~/.ssh/id_router.pub";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          CanonicalizeHostname = "yes";
          CanonicalDomains = "crdant.net walrus-shark.ts.net crdant.io.beta.tailscale.net";
          IdentitiesOnly = "yes";
        };
        "unifi.crdant.net" = {
          HostName = "unifi.crdant.net";
          User = "root";
          IdentityFile = "~/.ssh/id_unifi.pub";
          HostKeyAlgorithms = "+ssh-rsa";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          IdentitiesOnly = "yes";
        };
        "10.13.6.204 bridge.things.crdant.net homebridge.things.crdant.net" = {
          User = "pi";
        };
      };
    };
  };
}

