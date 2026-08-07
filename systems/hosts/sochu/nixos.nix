{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  hardware.asahi.enable = true;

  # systemd-based stage 1 is required for FIDO2 unlock (systemd-cryptsetup);
  # the scripted initrd only supports passphrases
  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices.cryptroot = {
    # REPLACE after reinstall: UUID of the LUKS partition (blkid on the raw
    # root partition, not the mapped device)
    device = "/dev/disk/by-uuid/REPLACE-WITH-LUKS-PARTITION-UUID";
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
