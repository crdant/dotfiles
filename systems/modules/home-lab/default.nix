{ pkgs, lib, options, ... }:

let 
  supportsVirtualisation = builtins.hasAttr "virtualisation" options;
  vmwareConfig = lib.optionalAttrs supportsVirtualisation {
    virtualisation = {
      vmware = {
        guest = { 
          enable = true;
          headless = true;
        };
      };
    };
  };
in lib.mkMerge [
  vmwareConfig
  {
    services = { 
      ntp.enable = false;
      chrony.enable = false;
      timesyncd.enable = false;
    };
  }
]
