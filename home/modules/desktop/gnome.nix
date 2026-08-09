# GNOME preferences, captured from the live session on sochu. Imported by the
# desktop module unconditionally; everything is guarded so Darwin homes are
# untouched.
{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in {
  dconf.settings = lib.mkIf isLinux {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/mutter" = {
      # A fixed set of workspaces instead of GNOME's grow-as-you-go default.
      dynamic-workspaces = false;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/map-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/map-d.svg";
      picture-options = "zoom";
      color-shading-type = "solid";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/map-l.svg";
      picture-options = "zoom";
      color-shading-type = "solid";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
  };

  # Display scale lives in mutter's monitors.xml, not dconf. 150% on sochu's
  # Retina panel — mutter's automatic 200% renders everything too large.
  # mutter matches entries by connector and mode, so hosts with a different
  # panel ignore this one. `force` lets activation reclaim the file after the
  # Displays panel rewrites it (a GUI change replaces the symlink with a plain
  # file, which would otherwise fail the next switch).
  xdg.configFile."monitors.xml" = lib.mkIf isLinux {
    force = true;
    text = ''
      <monitors version="2">
        <configuration>
          <layoutmode>logical</layoutmode>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1.5</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>eDP-1</connector>
                <vendor>unknown</vendor>
                <product>unknown</product>
                <serial>unknown</serial>
              </monitorspec>
              <mode>
                <width>3024</width>
                <height>1890</height>
                <rate>120.000</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    '';
  };
}
