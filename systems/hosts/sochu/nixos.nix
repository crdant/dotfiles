{ inputs, outputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  hardware.asahi.enable = true;

  # Wi-Fi-only laptop: NetworkManager instead of the networkd stack that
  # system-defaults/home-lab push for servers (mkForce because they set it
  # at normal priority)
  networking.networkmanager.enable = true;
  networking.useNetworkd = lib.mkForce false;
  systemd.network.enable = lib.mkForce false;

  # systemd-based stage 1 is required for FIDO2 unlock (systemd-cryptsetup);
  # the scripted initrd only supports passphrases
  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/2d3429b5-e164-4d4c-b502-cffda278a6ff";
    # try an enrolled YubiKey first (systemd-cryptenroll --fido2-device=auto),
    # fall back to the passphrase prompt if no token is present
    crypttabExtraOpts = [ "fido2-device=auto" ];
  };

  # apple-silicon-support already puts the internal keyboard transports in the
  # initrd (spi-hid-apple, dockchannel-hid, usbhid, hid_generic); hid_apple is
  # the HID driver that binds Apple keyboards and the Asahi kernel builds it as
  # a module (HID_APPLE = module), so include it for the LUKS prompt. Unverified
  # on this machine — keep a USB keyboard handy for the first encrypted boot.
  boot.initrd.availableKernelModules = [ "hid_apple" ];
}
