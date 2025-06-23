{ inputs, outputs, config, pkgs, lib, ... }:
let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {

  home = {
    packages = with pkgs; [
      govc
      minio-client
      powershell
    ] ++ lib.optionals isDarwin [
      tart
    ];
    
    file = {
      ".config/ssh/config.d" = {
        source = ./config/ssh/config.d;
        recursive = true;
      };
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      "Library/Application Support/espanso/match/snippets.yml" = {
        source = ./config/espanso/match/snippets.yml;
      };
    };
  };

  programs = {
    ssh = {
      matchBlocks = {
        "10.13.6.204 bridge.things.crdant.net homebridge.things.crdant.net" = {
          user = "pi";
        };
        "rye.lab.shortrib.net bourbon.lab.shortrib.net scotch.lab.shortrib.net potstill.lab.shortrib.net shine.lab.shortrib.net malt.lab.shortrib.net vcenter.lab.shortrib.net" = {
          user = "root";
          identityFile = "~/.ssh/id_homelab.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
          };
        };
      };
    };
  };
}
