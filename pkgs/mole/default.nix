{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mole";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "tw93";
    repo = "Mole";
    rev = "V${version}";
    sha256 = "sha256-dalmW3W/seGZreSWuYP7JN/nMUbs3WyDHzKU83EveeY=";
  };

  vendorHash = "sha256-LznLZ0NO8VBWP95ReAVORUMIDhh7/pgTY5mGNN2tND8=";

  postInstall = ''
    # Create the libexec directory structure
    mkdir -p $out/libexec/mole/bin

    # Install the main shell scripts
    install -Dm755 $src/mole $out/libexec/mole/mole
    install -Dm755 $src/mo $out/libexec/mole/mo

    # Copy the library directory
    cp -r $src/lib $out/libexec/mole/

    # Copy the bin shell scripts
    for f in $src/bin/*.sh; do
      install -Dm755 "$f" "$out/libexec/mole/bin/$(basename "$f")"
    done

    # Copy Go binaries to the mole bin directory so scripts can find them
    cp $out/bin/analyze $out/libexec/mole/bin/
    cp $out/bin/status $out/libexec/mole/bin/

    # Create wrapper scripts in bin
    rm -f $out/bin/analyze $out/bin/status
    cat > $out/bin/mo << 'EOF'
#!/usr/bin/env bash
exec "@out@/libexec/mole/mole" "$@"
EOF
    chmod +x $out/bin/mo
    substituteInPlace $out/bin/mo --replace-fail '@out@' "$out"
  '';

  meta = with lib; {
    homepage = "https://github.com/tw93/Mole";
    description = "A macOS deep uninstaller for thorough app removal";
    mainProgram = "mo";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
