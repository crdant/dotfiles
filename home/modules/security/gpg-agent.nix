{ inputs, outputs, config, pkgs, lib, gitEmail, secretsFile ? null, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  
  # Security-related packages
  home = {
    file = {
      ".gnupg/gpg-agent.conf" = {
        source = ./config/gpg-agent/gpg-agent.conf;
        recursive = true;
      };
    } ;
  };

  programs = {
    zsh = {
      initContent = ''
        if [[ -z $SSH_TTY ]]; then
          plugins+=( gpg-agent )
        else
          # When SSHed in, set GPG_TTY so pinentry-mac can fall back to curses mode
          export GPG_TTY=$(tty)
          gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
        fi

        source $ZSH/oh-my-zsh.sh
      '';
    };
  };
  
}
