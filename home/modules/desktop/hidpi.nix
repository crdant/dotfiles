# GNOME HiDPI settings for a Retina laptop. Not imported anywhere yet: a
# host's home configuration (or a later merge) wires it in alongside the
# desktop module.
#
# The default stance is clean 200% integer scaling, which mutter selects
# automatically on a ~254 ppi panel and persists per-monitor in
# ~/.config/monitors.xml — no dconf keys required. Everything below is
# therefore opt-in tuning, left commented until a real display asks for it.
{ ... }:

{
  dconf.settings = {
    # "org/gnome/desktop/interface" = {
    #   # Scales text only, on top of the monitor scale. Use for in-between
    #   # sizes (e.g. 2x monitor scale feels big, so 2x * 0.9 text) instead
    #   # of reaching for fractional monitor scaling.
    #   text-scaling-factor = 0.9;
    # };

    # "org/gnome/mutter" = {
    #   # Fractional monitor scaling (125%/150%/175% in Display settings) is
    #   # still experimental in the GNOME shipped with nixpkgs 26.05 and
    #   # hidden behind this flag. It also renders XWayland apps blurry
    #   # (scaled up from a smaller buffer) unless xwayland-native-scaling
    #   # is enabled too — see docs/hidpi.md.
    #   experimental-features = [
    #     "scale-monitor-framebuffer"
    #     "xwayland-native-scaling"
    #   ];
    # };
  };
}
