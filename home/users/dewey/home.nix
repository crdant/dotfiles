{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, profile, ... }:

{
  imports = [
    ../../profiles/${profile}.nix
  ];

  programs.zsh = {
    oh-my-zsh = {
      theme = lib.mkForce "fino";
      custom = lib.mkForce "";
    };

    localVariables = {
      COMPLETION_WAITING_DOTS = true;
    };

    shellAliases = {
      more = "less -X";
      lsock = "sudo /usr/sbin/lsof -i -P";
    };

    initExtra = ''
      setopt nobeep
      setopt inc_append_history
      setopt auto_cd
      setopt correct
    '';
  };

  sops = {
    gnupg.home = lib.mkForce null;
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
  };
}
