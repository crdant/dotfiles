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

      # Bootstrap the public keyring on a fresh machine. Private key material
      # lives on the YubiKey; these are public keys + ownertrust only, imported
      # additively (mutableKeys/mutableTrust stay at their `true` defaults).
      publicKeys = [
        { source = ./config/gnupg/keys/crdant-shortrib.asc; trust = "ultimate"; }  # current key (card)
        { source = ./config/gnupg/keys/crdant-2021.asc; trust = "ultimate"; }      # older personal key
        { source = ./config/gnupg/keys/github-web-flow.asc; trust = "full"; }      # GitHub web-flow (2024)
        { source = ./config/gnupg/keys/github-web-flow-2017.asc; trust = "full"; } # GitHub web-flow (2017)
      ];
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

  # Manage gpg-agent.conf directly rather than via services.gpg-agent on darwin.
  # That module runs `gpg-agent --supervised`, which only implements systemd's
  # LISTEN_FDNAMES socket-activation protocol; macOS launchd doesn't speak it and
  # mainline GnuPG has no launchd support, so the supervised agent exits (code 2)
  # and its launchd ssh socket accepts connections that nothing services -> hang.
  # (home-manager#5997, home-manager#4413, gnupg-devel 2018-06.) Instead the agent
  # runs as a normal daemon, launched by the fish/zsh init, and SSH_AUTH_SOCK is
  # pointed at the socket gpgconf actually reports (~/.gnupg/S.gpg-agent.ssh).
  home.file = lib.mkIf isDarwin {
    ".gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      default-cache-ttl 600
      max-cache-ttl 7200
      default-cache-ttl-ssh 600
      max-cache-ttl-ssh 7200
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';
  };

  # GUI apps get SSH_AUTH_SOCK from the launchd session env (the desktop module's
  # set-environment agent). Point it at the agent's ssh socket -- the path gpgconf
  # reports for the default homedir.
  guiEnvironment = lib.mkIf (options ? guiEnvironment) {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh";
  };
}
