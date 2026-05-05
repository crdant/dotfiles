{ inputs, outputs, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  programs.fish = {
    enable = true;

    shellAliases = {
      more = "less -X";
      pd = "pushd";
      pop = "popd";
      sha1 = "/usr/bin/openssl sha1";
      rmd160 = "/usr/bin/openssl rmd160";
      lsock = "sudo /usr/sbin/lsof -i -P";
    };

    # Always-on environment parity with zsh's envExtra
    shellInit = ''
      set -gx XDG_CONFIG_HOME "${config.xdg.configHome}"

      # if rancher desktop is installed use its binaries ONLY for anything not already
      # installed system-wide
      if test -d $HOME/.rd
        fish_add_path --append $HOME/.rd/bin
      end
    '';

    interactiveShellInit = ''
      # Shell options parity (zsh setopt block)
      fish_vi_key_bindings
      set -U fish_greeting ""

      # SSH/GPG agent configuration
      # handle SSH differences between Prompt on iOS and a machine with Yubikey PGP available
      # if we're connected via a traditional SSH agent it's probably Prompt
      set -l gpg_ssh_sock (gpgconf --list-dirs agent-ssh-socket 2>/dev/null)
      set -l launchd_ssh_sock ""
      if command -v launchctl >/dev/null 2>&1
        set launchd_ssh_sock (launchctl getenv SSH_AUTH_SOCK 2>/dev/null)
      end

      if test -n "$SSH_AUTH_SOCK" \
          -a "$SSH_AUTH_SOCK" != "$gpg_ssh_sock" \
          -a "$SSH_AUTH_SOCK" != "$launchd_ssh_sock" \
          -a (readlink -f $SSH_AUTH_SOCK) != "$gpg_ssh_sock"
        # use ssh signing with the provided key
        set -gx GIT_CONFIG_COUNT 3
        set -gx GIT_CONFIG_KEY_0 gpg.format
        set -gx GIT_CONFIG_VALUE_0 ssh
        set -gx GIT_CONFIG_KEY_1 user.signingkey
        set -gx GIT_CONFIG_VALUE_1 ~/.ssh/id_charanda_enclave.pub
        set -gx GIT_CONFIG_KEY_2 gpg.ssh.allowedSignersFile
        set -gx GIT_CONFIG_VALUE_2 ~/.config/git/allowed-signers
      else
        if test -z "$SSH_AUTH_SOCK"
          set -gx SSH_AUTH_SOCK "$gpg_ssh_sock"
        end
      end

      # Rosé Pine Moon syntax highlighting
      # values from rose-pine/fish themes/Rosé Pine Moon.theme
      set -U fish_color_normal e0def4
      set -U fish_color_command c4a7e7
      set -U fish_color_keyword 9ccfd8
      set -U fish_color_quote f6c177
      set -U fish_color_redirection 3e8fb0
      set -U fish_color_end 908caa
      set -U fish_color_error eb6f92
      set -U fish_color_param ea9a97
      set -U fish_color_comment 908caa
      set -U fish_color_operator e0def4
      set -U fish_color_escape 3e8fb0
      set -U fish_color_autosuggestion 908caa
      set -U fish_color_cwd ea9a97
      set -U fish_color_user f6c177
      set -U fish_color_host 9ccfd8
      set -U fish_color_host_remote c4a7e7
      set -U fish_color_cancel e0def4
      set -U fish_color_search_match --background=232136
      set -U fish_pager_color_progress ea9a97
      set -U fish_pager_color_background --background=2a273f
      set -U fish_pager_color_prefix 9ccfd8
      set -U fish_pager_color_completion 908caa
      set -U fish_pager_color_description 908caa
      set -U fish_pager_color_selected_background --background=393552
      set -U fish_pager_color_selected_prefix 9ccfd8
      set -U fish_pager_color_selected_completion e0def4
      set -U fish_pager_color_selected_description e0def4
    '';

    functions = {
      tmux-has-session = ''
        tmux has-session -t $argv[1] 2>/dev/null
      '';

      smug-session = ''
        set -l session $argv[1]

        if not test -d "$XDG_RUNTIME_DIR/ssh"
          mkdir -p "$XDG_RUNTIME_DIR/ssh"
        end
        if test "$SSH_AUTH_SOCK" != "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
          ln -sf (readlink -f $SSH_AUTH_SOCK) "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
          set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
        end
        if test -f (pwd)/.smug.yml
          smug start
        else
          smug start $session
        end
      '';

      fullscreen = ''
        smug-session fullscreen
      '';

      window = ''
        smug-session window
      '';
    };
  };
}
