{ pkgs, ... }:
let
  addressbook = import ./defaults/addressbook.nix ;
  amphetamine = import ./defaults/amphetamine.nix ;
  appstore = import ./defaults/appstore.nix ;
  bartender = import ./defaults/amphetamine.nix ;
  diskutil = import ./defaults/diskutil.nix ;
  ical = import ./defaults/ical.nix ;
  quicktime = import ./defaults/quicktime.nix ;
  safari = import ./defaults/safari.nix ;
  textedit = import ./defaults/textedit.nix ;
  vimr = import ./defaults/vimr.nix ;
in
{
  system = {
    defaults = { 
      CustomUserPreferences = {
        "com.apple.AddressBook" = addressbook;
        "com.if.Amphetamine" = amphetamine;
        "com.apple.appstore" = appstore;
        "com.surteesstudios.Bartender" = bartender;
        "com.apple.DiskUtility" = diskutil;
        "com.apple.iCal" = ical;
        "com.apple.QuickTimePlayerX" = quicktime;
        # "com.apple.Safari" = safari;
        "com.apple.TextEdit" = textedit;
        "com.qvacua.VimR" = vimr;
      };
    };
  };
}
