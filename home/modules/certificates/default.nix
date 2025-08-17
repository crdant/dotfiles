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
      ".step/authorities/shortrib/config/defaults.json" = {
        text = builtins.toJSON {
          ca-url = "https://certificates.shortrib.run";
          fingerprint = "21f11fd88a54b9a311190f6918073b6c98a1a10b5ba83f8c0f078a63c55b80ea";
          root = "${config.home.homeDirectory}/.step/authorities/shortrib/certs/root_ca.crt";
          redirect-url = "";
        };
      };
      ".step/authorities/shortrib/certs" = {
        source = ./config/step/authorities/shortrib/certs;
      };
      ".step/profiles" = {
        source = ./config/step/profiles;
      };
     ".step/contexts.json" = {
        source = ./config/step/contexts.json;
      };
     ".step/current-context.json" = {
        source = ./config/step/current-context.json;
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
