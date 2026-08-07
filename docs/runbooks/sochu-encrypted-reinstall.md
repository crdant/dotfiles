# sochu: reinstall NixOS root with LUKS2 encryption

sochu is an Apple Silicon MacBook dual-booting macOS and NixOS (Asahi). This
runbook reinstalls only the NixOS root filesystem, converting it from plain
ext4 to LUKS2 with a passphrase (fallback) plus a FIDO2 YubiKey (primary
unlock, enrolled after first boot).

Partitions are **not** resized. The ESP (`/boot`, vfat, holds m1n1 / U-Boot /
Asahi firmware) is **untouched** — reformatting it would break the machine's
boot chain.

The repo already declares the encrypted layout on branch
`feature/crdant/encrypts-sochu-root`:

- `systems/hosts/sochu/nixos.nix` — `boot.initrd.systemd.enable`,
  `boot.initrd.luks.devices.cryptroot` with `fido2-device=auto`
- `systems/hosts/sochu/hardware-configuration.nix` — root on the mapped device

Both contain `REPLACE-WITH-...` placeholder UUIDs that this runbook fills in.

## 0. Before wiping: back up SSH host keys (optional)

Keeps sochu's host identity stable so other machines' `known_hosts` entries
survive the reinstall. From the running NixOS system:

```sh
sudo tar czf sochu-ssh-host-keys.tar.gz -C / etc/ssh/ssh_host_ed25519_key \
  etc/ssh/ssh_host_ed25519_key.pub etc/ssh/ssh_host_rsa_key \
  etc/ssh/ssh_host_rsa_key.pub
```

Copy the tarball somewhere off the machine (another host, a USB stick — not
the partition about to be reformatted).

Also note the current root partition device now, while it is easy to check:

```sh
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,UUID
```

The root is the ext4 partition mounted at `/` (an `nvme0n1pN` partition); the
ESP is the vfat partition at `/boot`. Write both device names down.

## 1. Boot the installer

Boot the nixos-apple-silicon installer USB: hold the power button, choose the
NixOS boot option, and boot the USB installer image. (Keep a USB keyboard on
hand for the whole procedure — the internal-keyboard initrd modules are
unverified, see the note in `nixos.nix`.)

Get networking up and become root:

```sh
sudo -i
```

## 2. Encrypt the existing root partition

Substitute the real root partition device from step 0 for `/dev/nvme0n1pN`
below. Double-check with `lsblk` from the installer — device numbering should
match, but verify the size and that it is **not** the vfat ESP.

```sh
cryptsetup luksFormat --type luks2 /dev/nvme0n1pN
cryptsetup open /dev/nvme0n1pN cryptroot
mkfs.ext4 /dev/mapper/cryptroot
```

`luksFormat` prompts for the passphrase — this stays as the fallback unlock
after the YubiKey is enrolled, so pick something memorable and record it.

## 3. Mount and harvest UUIDs

```sh
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1pM /mnt/boot   # the existing vfat ESP — mount, do NOT format
nixos-generate-config --root /mnt
```

Read the generated `/mnt/etc/nixos/hardware-configuration.nix` and copy the
UUIDs into the repo (the generated file itself is not used — the repo's
version is canonical):

- `boot.initrd.luks.devices."cryptroot".device` UUID → replaces
  `REPLACE-WITH-LUKS-PARTITION-UUID` in `systems/hosts/sochu/nixos.nix`
  (also available as `blkid /dev/nvme0n1pN`)
- `fileSystems."/"` UUID → replaces `REPLACE-WITH-INNER-FS-UUID` in
  `systems/hosts/sochu/hardware-configuration.nix`
  (also available as `blkid /dev/mapper/cryptroot`)
- confirm the `fileSystems."/boot"` UUID still matches the repo (`EDAC-1406`
  — it will, since the ESP was not reformatted)

Update the repo (from another machine, or clone it in the installer), commit,
and make the updated flake reachable from the installer.

## 4. Install

```sh
nixos-install --flake 'git+https://github.com/crdant/dotfiles?ref=feature/crdant/encrypts-sochu-root#sochu' --impure
```

`--impure` is required: the repo's flake relies on `pure-eval = false`, which
is configured on the installed machine's nix.conf but is not live in the
installer environment.

If the host keys were backed up in step 0, restore them before rebooting:

```sh
tar xzf sochu-ssh-host-keys.tar.gz -C /mnt
```

## 5. First boot: passphrase test

Reboot into NixOS. The initrd should prompt for the LUKS passphrase (it will
also probe for a FIDO2 token because of `fido2-device=auto`; with nothing
enrolled it falls through to the passphrase). If the internal keyboard does
not respond at the prompt, use the USB keyboard and note it for follow-up.

Do not enroll the YubiKey until a plain passphrase boot has succeeded.

## 6. Enroll the YubiKey

From the booted system, with the YubiKey inserted:

```sh
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1pN
```

It asks for the existing passphrase, then for a touch on the YubiKey. Verify
with:

```sh
sudo systemd-cryptenroll /dev/nvme0n1pN
```

which should list slot 0 (password) and a fido2 slot. Reboot once more: the
initrd should unlock via the YubiKey (touch when it blinks), and a boot
without the key inserted should still fall back to the passphrase prompt.
