{ inputs, config, pkgs, lib, secretsFile ? null, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = lib.mkIf (secretsFile != null) {
    defaultSopsFile = secretsFile;
    gnupg = {
      home = "${config.home.homeDirectory}/.gnupg";
    };
  };

  # Force sops-nix activation to run after systemd reloads its units,
  # otherwise the first switch fails with "Unit sops-nix.service not found"
  home.activation.reloadSystemdBeforeSops = lib.mkIf (isLinux && secretsFile != null) (
    lib.hm.dag.entryBetween [ "sops-nix" ] [ "reloadSystemd" ] ""
  );

  # Home Manager installs LaunchAgent plists in setupLaunchAgents, rather than
  # linkGeneration. SOPS must wait for its plist before bootstrapping the agent.
  home.activation.setupLaunchAgentsBeforeSops = lib.mkIf (pkgs.stdenv.isDarwin && secretsFile != null) (
    lib.hm.dag.entryBetween [ "sops-nix" ] [ "setupLaunchAgents" ] ""
  );
}
