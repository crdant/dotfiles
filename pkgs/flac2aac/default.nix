{ lib
, stdenvNoCC
, ruby
, flac
, atomicparsley
, makeWrapper
}:

stdenvNoCC.mkDerivation {
  pname = "flac2aac";
  version = "1.0.0";

  src = ./flac2aac.rb;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  # afconvert ships with macOS in /usr/bin, so it comes from the system PATH
  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/flac2aac/flac2aac.rb
    makeWrapper ${ruby}/bin/ruby $out/bin/flac2aac \
      --add-flags $out/share/flac2aac/flac2aac.rb \
      --prefix PATH : ${lib.makeBinPath [ flac atomicparsley ]} \
      --suffix PATH : /usr/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Transcode FLAC files to AAC with metadata";
    platforms = platforms.darwin;
    mainProgram = "flac2aac";
  };
}
