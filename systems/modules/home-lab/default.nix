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
  supportsNtp = builtins.hasAttr "ntp" options.services;
  disableNtp = lib.optionalAttrs supportsNtp {
    services = {
      ntp.enable = false;
    };
  };
  supportsChrony = builtins.hasAttr "chrony" options.services;
  disableChrony = lib.optionalAttrs supportsChrony {
    services = {
      chrony.enable = false;
    };
  };
  supportsTimesyncd = builtins.hasAttr "timestampd" options.services;
  disableTimesyncd = lib.optionalAttrs supportsTimesyncd {
    services = {
      timestampd.enable = false;
    };
  };
in lib.mkMerge [
  vmwareConfig
  disableNtp
  disableChrony
  disableTimesyncd
]
