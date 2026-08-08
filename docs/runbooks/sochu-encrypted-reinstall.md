# sochu: install NixOS with LUKS2 encryption and btrfs subvolumes

sochu is an Apple Silicon MacBook dual-booting macOS and NixOS (Asahi). This
runbook (re)installs the NixOS side: LUKS2 on the root partition with a
passphrase (fallback) plus a FIDO2 YubiKey with PIN (primary unlock, enrolled
after first boot), and btrfs on top split into `@` (system), `@home`, and
`@nix` subvolumes.

The ESP (`/boot`, vfat, holds m1n1 / U-Boot / Asahi firmware) and the small
Apple partitions (ISC, the 2.5 GB NixOS boot stub, recovery) are **never
touched** — reformatting any of them breaks the machine's boot chain.

The repo already declares the target layout on the sochu branch:

- `systems/hosts/sochu/nixos.nix` — systemd initrd,
  `boot.initrd.luks.devices.cryptroot` with `fido2-device=auto`, NetworkManager
- `systems/hosts/sochu/hardware-configuration.nix` — btrfs subvolume mounts

Two UUIDs get harvested during the install: the **LUKS partition** UUID goes in
`nixos.nix`'s `cryptroot` block (the single declaration — do **not** also add a
`boot.initrd.luks.devices` line to `hardware-configuration.nix`; duplicate
definitions with different values fail evaluation), and the ESP UUID in
`hardware-configuration.nix` if it changed (it won't, unless the ESP was
recreated).

## 0. Before wiping: back up SSH host keys (optional)

Keeps sochu's host identity stable so other machines' `known_hosts` entries
survive. From the running NixOS system:

```sh
sudo tar czf sochu-ssh-host-keys.tar.gz -C / etc/ssh/ssh_host_ed25519_key \
  etc/ssh/ssh_host_ed25519_key.pub etc/ssh/ssh_host_rsa_key \
  etc/ssh/ssh_host_rsa_key.pub
```

Copy the tarball off the machine, and restore into `/mnt/etc/ssh/` after
`nixos-install`, before the first boot.

## 1. Boot the installer USB

The Apple startup picker (hold the power button) only lists macOS and the
NixOS stub — USB drives never appear there; that's normal. Pick the NixOS
entry; m1n1 chainloads U-Boot, and U-Boot is where the USB gets chosen.

U-Boot may prefer the internal disk. If you land at a LUKS passphrase prompt
or the installed system, that's the internal disk — power off and interrupt
U-Boot instead: mash a key the moment the screen goes to text, then at `=>`:

```
usb start
bootflow scan -l          # list candidates; note the usb row's number
bootflow select <n>
bootflow boot
```

(`bootflow scan -b usb0` scans only USB; try `usb1` if empty. Plain
`bootflow scan -b` boots the *first* candidate found — usually the internal
disk — so don't use it here.) The installer boots to a shell with no LUKS
prompt; a passphrase prompt means you're in the wrong boot.

Get network with `nmtui` or `iwctl` if anything needs fetching, and
`sudo -i`.

## 2. Partitioning (only if the root partition doesn't exist yet)

Free space in the GPT does **not** appear in `lsblk` — unallocated gaps have
no device node. If the Linux root partition was deleted (e.g. to resize the
macOS/Linux split via the Asahi installer), create it in the gap:

```sh
cfdisk /dev/nvme0n1     # select the Free space row → New → full size →
                        # type "Linux filesystem" → Write
```

Leave every other partition alone. Note the numbers: on sochu the ESP is
`nvme0n1p4` and the root partition takes the next free number (`p6`, sitting
between the ESP and the recovery partition — that gap is where the old root
lived). Verify against sizes with `lsblk`; the root is the big one, the ESP
the ~500M vfat one.

Sizes read ~7% smaller in Linux tools than in `diskutil`: Apple speaks
decimal GB, Linux binary GiB. 800 GB ≈ 745 GiB; nothing is missing.

## 3. Encrypt, format, mount

```sh
cryptsetup luksFormat --type luks2 /dev/nvme0n1p6
cryptsetup open /dev/nvme0n1p6 cryptroot
mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

The passphrase chosen here is the permanent fallback — it must be typeable on
the console keyboard at boot.

Create the subvolumes and mount the tree the way the config expects:

```sh
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

mount -o subvol=@,compress=zstd /dev/mapper/cryptroot /mnt
mkdir -p /mnt/home /mnt/nix /mnt/boot
mount -o subvol=@home,compress=zstd /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount /dev/nvme0n1p4 /mnt/boot
```

## 4. Harvest UUIDs into the repo

```sh
blkid /dev/nvme0n1p6     # LUKS partition UUID → nixos.nix cryptroot block
blkid /dev/nvme0n1p4     # ESP UUID → hardware-configuration.nix (rarely changes)
```

`nixos-generate-config --root /mnt` shows what it would write, but the repo's
`hardware-configuration.nix` is already shaped for this layout — take UUIDs
from it, not structure. Watch for typos: it's `btrfs`, and the LUKS line needs
its semicolon (both bit us once). Commit and push before installing.

## 5. Install

Prefer a local clone — it doubles as the machine's permanent checkout and
sidesteps nix's remote-fetch cache, which happily builds a stale branch tip:

```sh
git clone -b <branch> https://github.com/crdant/dotfiles \
  /mnt/home/crdant/workspace/dotfiles
nixos-install --flake /mnt/home/crdant/workspace/dotfiles#sochu --impure
```

If installing from a remote ref instead, always add
`--option tarball-ttl 0` so the fetch can't serve yesterday's branch.

`--impure` is required twice over: the machine's `pure-eval = false` nix.conf
isn't live in the installer, and the Asahi module reads the peripheral
firmware out of `/boot/asahi` at evaluation time, which pure evaluation
forbids.

Set the root password when prompted. Restore SSH host keys now if backed up.

## 6. First boot

Remove the USB stick and boot. Expect the LUKS passphrase prompt — the
console font is small until the HiDPI module lands, and the internal keyboard
should work (the Asahi kernel's transport drivers plus `hid_apple` are in the
initrd; keep a USB keyboard within reach the first time anyway).

Then:

```sh
passwd crdant           # as root; users are mutable on sochu — without this,
                        # console login as crdant fails as if the user
                        # doesn't exist
nmtui                   # join Wi-Fi via NetworkManager
```

## 7. Enroll the YubiKey

Enrollments are **additive** — each run burns a new LUKS slot, and a no-PIN
slot left behind means boot happily uses the weaker one. Enroll with the PIN
required, and wipe-and-redo in one command if fixing an earlier enrollment:

```sh
sudo systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=yes /dev/nvme0n1p6
# fixing a prior no-PIN enrollment (wipes ALL fido2 slots, then re-enrolls):
sudo systemd-cryptenroll --wipe-slot=fido2 --fido2-device=auto \
  --fido2-with-client-pin=yes /dev/nvme0n1p6
```

Enroll the backup key afterward, plain (no wipe flag), with the same PIN
option. The FIDO2 PIN is per-key (`ykman fido access change-pin`) and is not
the GPG PIN. Verify slots with `sudo systemd-cryptenroll /dev/nvme0n1p6`,
then reboot to test: key in → PIN + touch; key out → passphrase.

## 8. Home environment and secrets

As crdant (console, YubiKey plugged into sochu — its GPG applet decrypts the
sops secrets):

```sh
gpg --card-status                 # smartcard stack check; the config declares
                                  # all three layers it needs: pcscd + udev
                                  # rules, the polkit wheel rule, and
                                  # scdaemon's disable-ccid
gpg --import <public-key>         # fresh keyring needs the public key before
                                  # the card stubs are useful
cd ~/workspace/dotfiles
nix run github:nix-community/home-manager/release-26.05 -- switch \
  --flake .#crdant@aarch64-linux --impure -b backup
```

`sops-nix.service` runs headless and cannot show a pinentry. Once per boot
(or card replug), prime the PIN from any terminal — one interactive
`sops -d <file>` prompts pinentry-curses and leaves the card unlocked in
scdaemon — then `systemctl --user restart sops-nix.service` if it failed
before priming. After the first switch, `make user` and `make host` work from
the local clone like any other machine.
