{lib, stdenv, config, pkgs, vimUtils, writeShellScriptBin, makeWrapper, ...}:

let
  vimrCommand = "${pkgs.vimr}/Applications/VimR.app/Contents/Resources/vimr" ;
  wrapperArgs = config.programs.neovim.finalPackage.wrapperArgs  ;
  neovimArgs = ''
    --add-flags '--nvim' --add-flags '--cmd "set packpath^=${vimUtils.packDir config.programs.neovim.finalPackage.packpathDirs}"' \
    --add-flags '--cmd "set rtp^=${vimUtils.packDir config.programs.neovim.finalPackage.packpathDirs}"';
  '' ;
in stdenv.mkDerivation {
  pname = "vimr-wrapper";
  version = "${pkgs.vimr.version}";

  dontUnpack = true ;
  dontPatch  = true ;
  dontConfigure = true ;  
  dontBuild = true ;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    makeWrapper ${vimrCommand} $out/bin/vimr ${wrapperArgs} \
      ${neovimArgs}
    runHook postInstall
  '';
}
