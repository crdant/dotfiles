{ pkgs, ... }:
let
  addressbook = import ./defaults/addressbook.nix ;
  amphetamine = import ./defaults/amphetamine.nix ;
  appstore = import ./defaults/appstore.nix ;
  bartender = import ./defaults/amphetamine.nix ;
  diskutil = import ./defaults/diskutil.nix ;
  ical = import ./defaults/ical.nix ;
  iterm2 = import ./defaults/iterm2.nix ;
  memoryclean = import ./defaults/memoryclean.nix ;
  print = import ./defaults/print.nix ;
  quicktime = import ./defaults/quicktime.nix ;
  safari = import ./defaults/safari.nix ;
  tailscale = import ./defaults/tailscale.nix ;
  textedit = import ./defaults/textedit.nix ;
  todoist = import ./defaults/todoist.nix ;
  vimr = import ./defaults/vimr.nix ;
in
{
  homebrew = {
    brews = [
      "swiftformat"
      "xcode-build-server"
    ];
    casks = [
      "claude"
      "obs"
      "postman"
      "raspberry-pi-imager"
      "snowflake-snowsql"
      "superhuman"
    ];
  };

  system = {
    defaults = { 
      CustomUserPreferences = {
        # "com.apple.AddressBook" = addressbook;
        "com.if.Amphetamine" = amphetamine;
        "com.apple.appstore" = appstore;
        "com.surteesstudios.Bartender" = bartender;
        "com.apple.DiskUtility" = diskutil;
        "com.apple.iCal" = ical;
        "com.apple.QuickTimePlayerX" = quicktime;
        # "com.apple.Safari" = safari;
        "com.apple.TextEdit" = textedit;
        "com.qvacua.VimR" = vimr;
        "com.fiplab.memoryclean3" = memoryclean ;
        "io.tailscale.ipn.macos" = tailscale ;
        "org.cups.PrintingPrefs" = print ;
        "com.todoist.mac.Todoist" = todoist ;
        "com.googlecode.iterm2" = iterm2 ;
      };
    };
  };
}
