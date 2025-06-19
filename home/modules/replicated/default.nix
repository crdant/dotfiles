{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Kubernetes and container-related packages
  home = {
    packages = with pkgs; [
      instruqt
      kots
      replicated
      troubleshoot-sbctl
    ] ++ lib.optionals isDarwin [
      teams
    ];
    file = lib.optionalAttrs isDarwin {
      "Library/Colors/Replicated.clr" = {
        source = ./config/palettes/Replicated.clr;
        recursive = true;
      };
      "Library/Application Support/espanso/match/replicated.yml" = {
        source = ./config/espanso/match/replicated.yml;
      };
    };
  };  

  sops = {
    secrets = {
      "slack/shortrib/slackernews/userToken" = {};
      "slack/shortrib/slackernews/botToken" = {};
    };
    
    templates = lib.optionalAttrs isDarwin {
      "slackernews.yml" = {
        path = "${config.home.homeDirectory}/Library/Application Support/espanso/match/slackernews.yml";
        mode = "0600";
        content = 
          let 
            content = (pkgs.formats.yaml { }).generate "slackernews.yaml" {
              matches = [
                {
                  trigger = ";id";
                  replace = "4375036420002.5820986269254";
                }
                {
                trigger = ";secret";
                replace = "7d75b102878692827aa65b5f564402e7";
                }
                {
                  trigger = ";bot";
                  replace = "${config.sops.placeholder."slack/shortrib/slackernews/botToken"}";
                }
                {
                  trigger = ";user";
                  replace = "${config.sops.placeholder."slack/shortrib/slackernews/userToken"}";
                }
            ];
          };
          in builtins.readFile content;
        };
    };
  };
}

