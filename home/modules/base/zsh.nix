{ inputs, outputs, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      custom = "$HOME/workspace/oh-my-zsh-custom";
      theme = "crdant";

      plugins = [
        "git"
        "gh"
        "tmux"
        "emoji"
        "history-substring-search"
        "zoxide"
      ] ++ lib.optionals isDarwin [
        "brew"
        "iterm2"
        "macos"
        "pasteboard"
      ];
    };

    localVariables = {
      COMPLETION_WAITING_DOTS = true;
    };

    shellAliases = {
      more = "less -X";
      pd = "pushd";
      pop = "popd";
      sha1 = "/usr/bin/openssl sha1";
      rmd160 = "/usr/bin/openssl rmd160";
      lsock = "sudo /usr/sbin/lsof -i -P";
    };

    initContent = lib.mkMerge [
      # Completion paths - before compinit
      (lib.mkOrder 550 ''
        fpath+=($HOME/workspace/oh-my-zsh-custom/completions)
      '')

      # Shell options
      (lib.mkOrder 600 ''
        setopt vi
        setopt nobeep
        setopt inc_append_history
        setopt auto_cd
        setopt bash_auto_list
        setopt no_hup
        setopt correct
        setopt no_always_last_prompt
        setopt complete_aliases
        unsetopt hist_verify
      '')

      # SSH/GPG agent configuration
      (lib.mkOrder 700 ''
        # handle SSH differences between Prompt on iOS and a machine with Yubikey PGP available
        # if we're connected via a traditional SSH agent it's probably Prompt
        GPG_AGENT_SSH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        LAUNCHD_SSH_SOCK=$(command -v launchctl &>/dev/null && launchctl getenv SSH_AUTH_SOCK 2>/dev/null)
        if [[ -n "$SSH_AUTH_SOCK" \
           && "$SSH_AUTH_SOCK" != "$GPG_AGENT_SSH_SOCK" \
           && "$SSH_AUTH_SOCK" != "$LAUNCHD_SSH_SOCK" \
           && $(readlink -f $SSH_AUTH_SOCK) != "$GPG_AGENT_SSH_SOCK" ]]
        then
          # use ssh signing with the provided key
          export GIT_CONFIG_COUNT=3
          export GIT_CONFIG_KEY_0=gpg.format
          export GIT_CONFIG_VALUE_0=ssh
          export GIT_CONFIG_KEY_1=user.signingkey
          export GIT_CONFIG_VALUE_1=~/.ssh/id_charanda_enclave.pub
          export GIT_CONFIG_KEY_2=gpg.ssh.allowedSignersFile
          export GIT_CONFIG_VALUE_2=~/.config/git/allowed-signers
        else
          if [[ -z "$SSH_AUTH_SOCK" ]]; then
            export SSH_AUTH_SOCK="$GPG_AGENT_SSH_SOCK"
          fi
        fi
      '')

      # Shell functions
      (lib.mkOrder 800 ''
        function tmux-has-session() {
          session=$1
          tmux has-session -t $session 2>/dev/null
        }

        function smug-session() {
          session=$1

          if [[ ! -d "$XDG_RUNTIME_DIR/ssh" ]]; then
            mkdir -p "$XDG_RUNTIME_DIR/ssh"
          fi
          if [[ "SSH_AUTH_SOCK" != "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session" ]]; then
            ln -sf $(readlink -f $SSH_AUTH_SOCK) "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
          fi
          if [[ -f $(pwd)/.smug.yml ]]; then
            smug start
          else
            smug start $session
          fi
        }

        function fullscreen() {
          smug-session fullscreen
        }

        function window() {
          smug-session window
        }
      '')
    ];

    envExtra = ''
      export XDG_CONFIG_HOME="${config.xdg.configHome}"

      # if rancher desktop is installed use it's binaries ONLY for anything not already
      # installed system-wide
      if [[ -d $HOME/.rd ]] ; then
        export PATH=$PATH:"$HOME/.rd/bin"
      fi

      unset RPS1
    '';
  };
}
