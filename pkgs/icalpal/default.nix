{ lib
, stdenv
, fetchFromGitHub
, ruby
, bundlerEnv
, libyaml
, sqlite
, makeWrapper
}:

let
  version = "4.1.1";

  # Create a bundler environment with all the dependencies pre-installed
  gems = bundlerEnv {
    name = "icalpal-gems-${version}";
    inherit ruby;
    gemdir = ./.;
    gemConfig = {
      psych = attrs: {
        buildInputs = [ libyaml ];
      };
      sqlite3 = attrs: {
        buildInputs = [ sqlite ];
        buildFlags = [ "--enable-system-libraries" ];
      };
    };
  };
in
stdenv.mkDerivation {
  pname = "icalpal";
  inherit version;

  src = fetchFromGitHub {
    owner = "ajrosen";
    repo = "icalPal";
    rev = "icalPal-${version}";
    hash = "sha256-NWFXnp06ln5JOc08U4ZVFrSBijmNamKbUj0Djo9c8ZQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ gems ruby ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install in the structure expected by the script
    # bin/icalPal expects ../lib/ to contain the ruby files
    mkdir -p $out/share/icalpal/bin $out/share/icalpal/lib $out/bin
    cp bin/icalPal $out/share/icalpal/bin/
    cp lib/*.rb $out/share/icalpal/lib/

    # Create wrapper that sets up the gem path
    makeWrapper ${ruby}/bin/ruby $out/bin/icalPal \
      --set GEM_PATH "${gems}/lib/ruby/gems/${ruby.version.libDir}" \
      --add-flags "$out/share/icalpal/bin/icalPal"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line tool to query macOS Calendar and Reminders";
    homepage = "https://github.com/ajrosen/icalPal";
    license = licenses.gpl3Plus;
    platforms = platforms.darwin;
    mainProgram = "icalPal";
  };
}
