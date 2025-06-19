{ pkgs, lib, options, ... }:

let 
  supportsVirtualisation = builtins.hasAttr "virtualisation" options;
  vmwareConfig = lib.optionalAttrs supportsVirtualisation {
    virtualisation = {
      vmware = {
        guest.enable = true ;
      };
    };
  };
in lib.mkMerge [
  vmwareConfig
]
