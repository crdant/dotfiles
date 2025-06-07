{ inputs, outputs, config, pkgs, lib, ... }:

{
  # Homelab-specific SSH configurations
  programs = {
    ssh = {
      matchBlocks = {
         "exit.crdant.net" = {
          hostname = "exit.crdant.net";
          user = "arceus";
          identityFile = "~/.ssh/id_router.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            canonicalizeHostName = "yes";
            canonicalDomains = "crdant.net walrus-shark.ts.net crdant.io.beta.tailscale.net";
            identitiesOnly = "yes";
          };
        };
        "router" = {
          hostname = "router";
          user = "arceus";
          identityFile = "~/.ssh/id_router.pub";
          extraOptions = {
            identityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
            canonicalizeHostName = "yes";
            canonicalDomains = "lab.shortrib.net walrus-shark.ts.net crdant.io.beta.tailscale.net";
            identitiesOnly = "yes";
          };
        };
        "unifi.crdant.net" = {
          hostname = "unifi.crdant.net";
          user = "root";
          identityFile = "~/.ssh/id_unifi.pub";
          extraOptions = {
            hostKeyAlgorithms = "+ssh-rsa";
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
          };
        };
      };
    };
  };
}

