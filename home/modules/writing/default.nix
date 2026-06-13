{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pandoc
    readwise-cli
    spiral-cli
    texlive.combined.scheme-small
  ];

  programs.claude.plugins = [
    "draft-review-kit@draft-review-kit-local"
  ];
}
