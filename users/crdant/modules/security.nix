{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs._1password-shell-plugins.hmModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];
  
  # Security-related packages
  home.packages = with pkgs; [
    certbot-full
    cosign
    sops
    step-cli
    syft
    # yubico-pam
    yubico-piv-tool
    yubikey-manager
  ] ++ lib.optionals isLinux [
    gnupg
    opensc
  ];
  
  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
      ] ++ lib.optionals isDarwin [
        awscli2
        gh
        ngrok
      ];
    };
    
    ssh = {
      enable = true;
      hashKnownHosts = true;
      
      includes = [
        "${config.xdg.configHome}/ssh/config.d/*"
      ];
      
      # Common configs for all hosts
      extraConfig = ''
        User crdant
        IgnoreUnknown UseKeychain
        UseKeychain yes
        PasswordAuthentication no
      '';
    };
  };
  
  sops = {
    defaultSopsFile = ../secrets.yaml;  # Path to your secrets file
    gnupg = {
      home = "${config.home.homeDirectory}/.gnupg";
    };
    # Core security secrets
    secrets = {
      "github/token" = {};
      "slack/shortrib/slackernews/userToken" = {};
      "slack/shortrib/slackernews/botToken" = {};
      "mbta/apiKey" = {};
    };
    
    templates = {
      "goose/config.yaml" = {
        path = "${config.home.homeDirectory}/.config/goose/config.yaml";
        mode = "0600";
        content = 
          let 
            content = (pkgs.formats.yaml { }).generate "goose-config.yaml" {
              GOOSE_PROVIDER = "anthropic";
              GOOSE_MODEL = "claude-3-7-sonnet-latest";
              GOOSE_MODE = "smart_approve";
              extensions = {
                computercontroller = {
                  display_name = "Computer Controller";
                  enabled = true;
                  name = "computercontroller";
                  timeout = 300;
                  type = "builtin";
                };
                developer = {
                  display_name = "Developer Tools";
                  enabled = true;
                  name = "developer";
                  timeout = 300;
                  type = "builtin";
                };
                git = {
                  cmd = "${pkgs.uv}/bin/uvx";
                  args = [ "mcp-server-git" ];
                  description = "A Model Context Protocol server for Git repository interaction and automation.";
                  envs = {};
                  name = "git";
                  enabled = true;
                  timeout = 300;
                  type = "stdio";
                };
                mbta = {
                  args = [ ];
                  cmd = "${pkgs.mbta-mcp-server}/bin/mbta-mcp-server";
                  description = "My unofficial MBTA MCP Server";
                  enabled = true;
                  envs = {
                    MBTA_API_KEY = config.sops.placeholder."mbta/apiKey";
                  };
                  name = "mbta";
                  timeout = 300;
                  type = "stdio";
                };
                github = {
                  args = [ "stdio" ];
                  cmd = "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server";
                  description = "GitHub's official MCP Server";
                  enabled = true;
                  envs = {
                    GITHUB_PERSONAL_ACCESS_TOKEN = config.sops.placeholder."github/token";
                  };
                  name = "github";
                  timeout = 300;
                  type = "stdio";
                };
                google-maps = {
                  cmd = "${pkgs.nodejs_22}/bin/npx";
                  args = [ "-y" "@modelcontextprotocol/server-google-maps" ];
                  description = "MCP Server for the Google Maps API.";
                  envs = {
                    GOOGLE_MAPS_API_KEY = "${config.sops.placeholder."google/maps/apiKey"}";
                  };
                  name = "google-maps";
                  enabled = true;
                  timeout = 300;
                  type = "stdio";
                };
                memory = {
                  display_name = "Memory";
                  enabled = true;
                  name = "memory";
                  timeout = 300;
                  type = "builtin";
                };
              };
            };
          in builtins.readFile content;
      };
    } // lib.optionalAttrs isDarwin {
      "claude_desktop_config.json" = {
        path = "${config.home.homeDirectory}/Library/Application Support/Claude/claude_desktop_config.json";
        mode = "0600";
        content = builtins.toJSON {
            globalShortcut = "Cmd+Space";
            mcpServers = import ../config/mcp.nix { inherit config pkgs; };
          };
      };
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
  
  home.file = {
    ".gnupg" = {
      source = ../config/gnupg;
      recursive = true;
    };
    
    ".step" = {
      source = ../config/step;
      recursive = true;
    };
  } // lib.optionalAttrs isDarwin {
    ".gnupg/gpg-agent.conf" = {
      source = ../config/gpg-agent/gpg-agent.conf;
      recursive = true;
    };
  };
  
  xdg.configFile = {
    "ssh/config.d" = {
      source = ../config/ssh/config.d;
      recursive = true;
    };
    
    "git/allowed-signers" = {
      text = ''
        # allow FIDO SSH key on my personal Yubikey to sign commits
        chuck@crdant.io namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH76RbmzI1NX9SGvDUUnX0QAVmF5pzr6mHZNG2rd0jAoAAAABHNzaDo= crdant@grappa
        chuck@replicated.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH76RbmzI1NX9SGvDUUnX0QAVmF5pzr6mHZNG2rd0jAoAAAABHNzaDo= crdant@grappa
        chuck@rcrdant.io namespace="git" ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKZNf1+SIohm48DXEa1Xssz1ZV8oPxI3Uij1IyZrU3UmQeGkZeu+Vin88qX5UizFat8wd1P88CQk2yaRAIgPKOc=
        chuck@replicated.com namespace="git" ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKZNf1+SIohm48DXEa1Xssz1ZV8oPxI3Uij1IyZrU3UmQeGkZeu+Vin88qX5UizFat8wd1P88CQk2yaRAIgPKOc=
      '';
    };
  };
  
  programs.zsh = {
    oh-my-zsh.plugins = [
      "gpg-agent"
    ] ++ lib.optionals isDarwin [
      "gpg-agent"
    ];
    
    envExtra = ''
      export CERTBOT_ROOT="${config.xdg.dataHome}/certbot"
    '';
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