# HiDPI support

Support for high-density panels (Retina laptops, ~2x displays) on NixOS
hosts:

- `systems/modules/hidpi` — system level, opt-in per host. Enables
  `console.earlySetup` with a 32px Terminus font (`ter-v32n`) so the virtual
  console — including the LUKS passphrase prompt in the initrd — is legible,
  and sets `boot.loader.systemd-boot.consoleMode = "auto"` so the boot menu
  doesn't render at tiny native resolution. Darwin-safe via the usual
  `options` guard, though only NixOS hosts have any reason to import it.
- `home/modules/desktop/gnome.nix` — home level, GNOME preferences including
  the display scale. Imported by the desktop module; no-op on Darwin.

## Display scaling

Wayland compositors own display scaling at runtime. On sochu's ~254 ppi
panel mutter picks 200% automatically; 150% is the deliberate choice, and
the gnome module declares it in `~/.config/monitors.xml` (mutter's store for
per-monitor settings — the scale never touches dconf). Entries match by
connector and mode, so a host with a different panel falls back to mutter's
automatic pick. Do not add X11-era DPI settings, global `GDK_SCALE`-style
environment variables, or xrandr machinery — they fight the compositor.

In the GNOME shipped with current nixpkgs unstable (50.x), fractional
scaling has graduated out of `experimental-features`: the Displays panel
offers 125/150/175% directly, and the old `scale-monitor-framebuffer` and
`xwayland-native-scaling` keywords are no longer recognized. Earlier notes
here about enabling them no longer apply.

If a fractional scale ever feels wrong, `text-scaling-factor`
(`org/gnome/desktop/interface`) scales text only on top of the monitor
scale — the cheap way to get "slightly smaller than 2x" from an integer
monitor scale.

## Opting a host in

```nix
# systems/hosts/<host>/default.nix
imports = [ ../../modules/hidpi ];
```

The home-level GNOME settings need no per-host wiring — any Linux home using
the desktop module gets them.
