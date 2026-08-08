# HiDPI support for NixOS hosts with high-density panels (e.g. Retina
# laptops). Hosts opt in by importing this module directly; it is not part
# of any role. Wayland desktops (GNOME, COSMIC) handle display scaling at
# runtime, so this only covers what they can't: the early console and the
# boot menu.
{ pkgs, lib, options, ... }:

let
  # console/boot.loader only exist on NixOS; guard so the module stays
  # darwin-safe if a role ever pulls it in.
  supportsConsole = builtins.hasAttr "console" options;
  consoleConfig = lib.optionalAttrs supportsConsole {
    console = {
      # Load the font from the initrd so the LUKS passphrase prompt is
      # legible, not just the post-boot VTs.
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      packages = [ pkgs.terminus_font ];
    };

    # "keep" (the default) leaves the firmware's native-resolution mode,
    # which renders the boot menu tiny on a Retina panel; let systemd-boot
    # pick a readable mode instead. Harmless on hosts using another loader.
    boot.loader.systemd-boot.consoleMode = lib.mkDefault "auto";
  };
in (lib.mkMerge [
  consoleConfig
])
