{ lib
, stdenvNoCC
, ruby
, ffmpeg
, atomicparsley
, makeWrapper
}:

stdenvNoCC.mkDerivation {
  pname = "shn2aac";
  version = "1.0.0";

  src = ./shn2aac.rb;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  # afconvert ships with macOS in /usr/bin, so it comes from the system PATH
  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/shn2aac/shn2aac.rb
    makeWrapper ${ruby}/bin/ruby $out/bin/shn2aac \
      --add-flags $out/share/shn2aac/shn2aac.rb \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg atomicparsley ]} \
      --suffix PATH : /usr/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Transcode Shorten (SHN) files to AAC with metadata";
    platforms = platforms.darwin;
    mainProgram = "shn2aac";
  };
}
