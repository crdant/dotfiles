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

  home.file."Scripts/poke-messages.scpt".text = ''
    try
      tell application "Messages"
        if not running then
          launch
        end if
        set _chatCount to (count of chats)
      end tell
    on error
    end try
  '';

  launchd = {
    enable = true;
    agents = {
      "com.luca.poke-messages" = {
        enable = true;
        config = {
          Label = "com.luca.poke-messages";
          ProgramArguments = [
            "/usr/bin/osascript"
            "${homeDirectory}/Scripts/poke-messages.scpt"
          ];
          RunAtLoad = true;
          StartInterval = 300;
          StandardOutPath = "/tmp/poke-messages.log";
          StandardErrorPath = "/tmp/poke-messages.err";
        };
      };

      "com.luca.bluebubbles-server" = {
        enable = true;
        config = {
          Label = "com.luca.bluebubbles-server";
          ProgramArguments = [
            "/Applications/BlueBubbles.app/Contents/MacOS/BlueBubbles"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/tmp/bluebubbles.log";
          StandardErrorPath = "/tmp/bluebubbles.err";
        };
      };
    };
  };
}
