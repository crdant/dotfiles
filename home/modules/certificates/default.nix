{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Certificate management tools
  home = {
    packages = with pkgs; [
      certbot-full
      step-cli
    ];
  
    file = {
      ".step" = {
        source = ./config/step;
        recursive = true;
      };
    };
  };

  programs = {
    zsh = {
      envExtra = ''
        export CERTBOT_ROOT="${config.xdg.dataHome}/certbot"
      '';
    };
  };
  
  launchd = if isDarwin then {
    enable = true;
    agents = {
      "io.crdant.certbotRenewal" = {
        enable = true;
        config = {
          Label = "io.crdant.certbotRenewal";
          ProgramArguments = [
            "${pkgs.certbot}"
            "renew"
            "--config-dir"
            "${config.xdg.dataHome}/certbot"
            "--work-dir"
            "${config.xdg.stateHome}/certbot/var"
            "--logs-dir"
            "${config.xdg.stateHome}/certbot/logs"
          ];
          StartCalendarInterval = [
            {
              Weekday = 3;
              Hour = 15;
              Minute = 48;
            }
          ];
          RunAtLoad = true;
          StandardOutPath = "${config.xdg.stateHome}/certbot/renewal.out";
          StandardErrorPath = "${config.xdg.stateHome}/certbot/renewal.err";
        };
      };
    };
  } else {
    enable = false;
  };
}