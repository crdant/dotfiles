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
      ".step/authorities/shortrib-labs-e1/config/defaults.json" = {
        text = builtins.toJSON {
          ca-url = "https://shortrib-labs-e1.shortrib.run";
          fingerprint = "21f11fd88a54b9a311190f6918073b6c98a1a10b5ba83f8c0f078a63c55b80ea";
          root = "${config.home.homeDirectory}/.step/authorities/shortrib-labs-e1/certs/root_ca.crt";
        };
      };
      ".step/authorities/shortrib-labs-e1/certs" = {
        source = ./config/step/authorities/shortrib-labs-e1/certs;
      };
      ".step/authorities/shortrib-labs-r5/config/defaults.json" = {
        text = builtins.toJSON {
          ca-url = "https://shortrib-labs-r5.shortrib.run";
          fingerprint = "ef58d96cb3fc50eb18ad848e91919f360918f4846fbb9d704ad50c6c86b5d5a8";
          root = "${config.home.homeDirectory}/.step/authorities/shortrib-labs-r5/certs/root_ca.crt";
        };
      };
      ".step/authorities/shortrib-labs-r5/certs" = {
        source = ./config/step/authorities/shortrib-labs-r5/certs;
      };
      ".step/profiles" = {
        source = ./config/step/profiles;
      };
     ".step/contexts.json" = {
        source = ./config/step/contexts.json;
      };
    };

    activation.setStepContext = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "${config.home.homeDirectory}/.step/current-context.json" ]; then
        echo '{"context":"shortrib-labs-e1"}' > "${config.home.homeDirectory}/.step/current-context.json"
      fi
    '';
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
