{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  # Audio transcoding tools (rely on macOS afconvert)
  home.packages = with pkgs; lib.optionals isDarwin [
    flac2aac
    shn2aac
  ];
}
