{ pkgs, ... }:
let
  addressbook = import ./defaults/addressbook.nix ;
  appstore = import ./defaults/appstore.nix ;
  diskutil = import ./defaults/diskutil.nix ;
  ical = import ./defaults/ical.nix ;
  quicktime = import ./defaults/quicktime.nix ;
  safari = import ./defaults/safari.nix ;
  textedit = import ./defaults/textedit.nix ;
in
{
  system = {
    defaults = { 
      CustomUserPreferences = {
        "com.apple.AddressBook" = addressbook;
        "com.apple.appstore" = appstore;
        "com.apple.DiskUtility" = diskutil;
        "com.apple.iCal" = ical;
        "com.apple.QuickTimePlayerX" = quicktime;
        "com.apple.Safari" = safari;
        "com.apple.TextEdit" = textedit;
      };
    };
  };
}
