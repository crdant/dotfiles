{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pandoc
    readwise-cli
    unstable.rumdl
    texlive.combined.scheme-small
  ];

  programs.claude.plugins = [
    "draft-review-kit@draft-review-kit-local"
    "strategy@shortrib-labs"
    "taste@shortrib-labs"
    "writing@shortrib-labs"
  ];
}
