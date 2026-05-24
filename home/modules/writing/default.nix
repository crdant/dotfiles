{ pkgs, ... }:

{
  home.packages = with pkgs; [
    readwise-cli
    spiral-cli
  ];
}
