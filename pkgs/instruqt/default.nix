 { stdenv, lib, fetchzip, unzip, autoPatchelfHook }:
let
  os = if stdenv.isDarwin then "darwin" else "linux" ;
  arch = if stdenv.isAarch64 then "arm64" else "amd64";

  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in stdenv.mkDerivation rec {
  pname = "instruqt-cli";
  version = "2171-6e951ef";

  src = fetchzip {
    url = "https://github.com/instruqt/cli/releases/download/${version}/instruqt-${os}-${arch}.zip";
    sha256 = if isDarwin then
        "sha256-kP/3n0gfV14kAI68K3yPOFEfCBUvRtb04A58bQgddqo="
      else
        "sha256-w3cMvFNHOA8AqhCmew0Adtwuqp2i0L/IgTXdpH+sR9c=";
  };

  nativeBuildInputs = [ unzip ] ;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 source/instruqt $out/bin/instruqt
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://instruqt.com/";
    description = "CLI for the Instruqt platform. Instruqt is a flexible, hands-on lab experience for training, workshops, and go-to-market.";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
