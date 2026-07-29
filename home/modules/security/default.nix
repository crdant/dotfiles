{ inputs, outputs, options, config, pkgs, lib, gitEmail, secretsFile ? null, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs._1password-shell-plugins.hmModules.default
  ];

  # Security-related packages
  home = {
    packages = with pkgs; [
        age
        cosign
        sops
        syft
        tunnelmanager
        # yubico-pam
        yubico-piv-tool
        yubikey-manager
      ] ++ lib.optionals isLinux [
        gnupg
        opensc
      ];
  };

  programs = {
    # _1password-shell-plugins = {
    #   enable = true;
    #   plugins = with pkgs; [
    #   ];
    # };

    gpg = {
      enable = true;
      settings = {
        auto-key-retrieve = true;
        no-emit-version = true;
        default-key = "420FB4E016EF66D1A4AF58970805EEDF0FEA6ACD";
        # use SHA-512 when signing a key
        cert-digest-algo = "SHA512";
        # override recipient key cipher preferences; drop 3DES, prefer AES256
        personal-cipher-preferences = "AES256 AES192 AES CAST5";
        # override recipient key digest preferences; drop SHA-1, prefer SHA-512
        personal-digest-preferences = "SHA512 SHA384 SHA256 SHA224";
        # drop SHA-1 and 3DES from preferences of newly created keys
        default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
        # reject SHA-1 signatures
        weak-digest = "SHA1";
        # never allow 3DES
        disable-cipher-algo = "3DES";
        # use AES256 for symmetric encryption
        s2k-cipher-algo = "AES256";
        # use SHA-512 for symmetric encryption
        s2k-digest-algo = "SHA512";
        # mangle the passphrase as many times as possible
        s2k-count = "65011712";
        # both short and long key IDs are insecure; use the full fingerprint
        keyid-format = "none";
        with-subkey-fingerprint = true;
      };
      dirmngrSettings.keyserver = "hkps://keys.openpgp.org";
    };

    neovim = {
      # Core plugins used everywhere
      plugins = with pkgs.vimPlugins; [
        nvim-sops
      ];

      initLua = ''
        vim.keymap.set('n', '<leader>ef', vim.cmd.SopsEncrypt, { desc = '[E]ncrypt [F]ile' })
        vim.keymap.set('n', '<leader>df', vim.cmd.SopsDecrypt, { desc = '[D]ecrypt [F]ile' })
      '';
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          User = "crdant";
          ForwardAgent = false;
          AddKeysToAgent = "yes";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = true;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "yes";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          PasswordAuthentication = "no";
        };
      };

      includes = [
        "${config.xdg.configHome}/ssh/config.d/*"
      ];

      # Common configs for all hosts
      extraConfig = ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
      '';
    };
  };

  # Run gpg-agent as a launchd-supervised service on darwin. This replaces the
  # hand-written ~/.gnupg/gpg-agent.conf and the oh-my-zsh gpg-agent plugin. The
  # agent's sockets move under /private/var/run/org.nix-community.home.gpg-agent/
  # (there's no option to keep them in ~/.gnupg); consumers of the ssh socket are
  # pointed at the new path below and in the homelab ssh RemoteForward rules.
  services.gpg-agent = lib.mkIf isDarwin {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;                 # restricted socket for agent forwarding
    pinentry.package = pkgs.pinentry_mac;
    defaultCacheTtl = 600;
    maxCacheTtl = 7200;
    defaultCacheTtlSsh = 600;
    maxCacheTtlSsh = 7200;
    # Our own fish/zsh init already derives SSH_AUTH_SOCK via `gpgconf` and adds
    # the Prompt-on-iOS fallback, so leave the module's shell hooks off to keep a
    # single source of truth.
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  # GUI apps get SSH_AUTH_SOCK from the launchd session env; point it at the
  # agent's relocated ssh socket instead of the old ~/.gnupg path. This is the
  # fixed path services.gpg-agent uses on darwin for the default homedir (see the
  # module's `gpgconf`). We hardcode it rather than read
  # config.launchd.agents.gpg-agent.*: guiEnvironment feeds the desktop module's
  # set-environment launchd agent, so reading launchd.agents back here is a cycle.
  guiEnvironment = lib.mkIf (options ? guiEnvironment && isDarwin) {
    SSH_AUTH_SOCK = "/private/var/run/org.nix-community.home.gpg-agent/S.gpg-agent.ssh";
  };
}
