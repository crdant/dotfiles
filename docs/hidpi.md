# HiDPI support

Support for high-density panels (Retina laptops, ~2x displays) on NixOS
hosts. Two opt-in modules, neither wired into any role:

- `systems/modules/hidpi` — system level. Enables `console.earlySetup` with a
  32px Terminus font (`ter-v32n`) so the virtual console — including the LUKS
  passphrase prompt in the initrd — is legible, and sets
  `boot.loader.systemd-boot.consoleMode = "auto"` so the boot menu doesn't
  render at tiny native resolution. Darwin-safe via the usual `options` guard,
  though only NixOS hosts have any reason to import it.
- `home/modules/desktop/hidpi.nix` — home level, GNOME dconf tuning. Currently
  all commented out, deliberately: see below.

## What the desktop environment handles itself

Wayland compositors own display scaling at runtime. On a ~254 ppi panel
mutter picks 200% automatically and persists the choice per-monitor in
`~/.config/monitors.xml`; COSMIC does its own equivalent. At clean integer
scaling nothing needs to be set declaratively, which is why the home module
ships empty. Do not add X11-era DPI settings, global `GDK_SCALE`-style
environment variables, or xrandr machinery — they fight the compositor.

The home module keeps two knobs commented for when integer scaling isn't
right:

- `text-scaling-factor` — scales text only, on top of the monitor scale. The
  cheap way to get "slightly smaller than 2x" without fractional scaling.
- `org/gnome/mutter` `experimental-features` — fractional monitor scaling
  (`scale-monitor-framebuffer`) is still experimental in the GNOME shipped
  with nixpkgs 26.05.

## XWayland blurriness under fractional scaling

XWayland clients can't render at fractional scales, so under fractional
scaling mutter scales their buffers up and they look blurry. GNOME's
`xwayland-native-scaling` experimental feature (paired with
`scale-monitor-framebuffer`) has XWayland apps render at the ceiling integer
scale and downscales, which sharpens well-behaved apps but can shrink UI in
apps that ignore the advertised X11 DPI. Integer scaling avoids the whole
problem — prefer it when the panel allows.

## Opting a host in

```nix
# systems/hosts/<host>/default.nix
imports = [ ../../modules/hidpi ];

# the host's home-manager configuration
imports = [ ../../modules/desktop/hidpi.nix ];  # adjust path as needed
```
