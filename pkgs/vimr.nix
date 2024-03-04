#! /nix/store/5qjcjxbfniz6vm9s8clf15wa2yira323-bash-5.1-p16/bin/bash -e
{ pkgs, stdenv }:

pkgs.writeShellScriptBin "vimr" ''
    export NVIM_SYSTEM_RPLUGIN_MANIFEST='${pkgs.neovim.outPath}/rplugin.vim'
''
