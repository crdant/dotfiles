{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  home.packages = with pkgs; [
    ffmpeg
  ] ++ lib.optionals isDarwin [
    # Audio transcoding tools (rely on macOS afconvert)
    flac2aac
    shn2aac
  ];
}
