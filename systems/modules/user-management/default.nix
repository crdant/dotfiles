{ pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # User and group management for multi-user systems
  
  users = {
    users.crdant = {};
    groups = {
      crdant = {
        gid = 1002;
      };
      ssher = {
        gid = 1001;
      };
    };
  } // lib.optionalAttrs isLinux {
    users.crdant = {
      uid = 1001;
    };
  };
}