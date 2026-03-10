{ stdenv, lib, pkgs, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config, bash, python3 }:
let
  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in
buildGoModule rec {
  pname = "rodney";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "rodney";
    rev = "v${version}";
    sha256 = "sha256-/iGsaMfK8zeUkTXwU63mAAb4VpsllG87EH8ycoFZs5k=";
  };

  vendorHash = "sha256-h4U43W3hLoF+p25/jNRaW8okeEzAZQEmKtwB5l4kGW4=";

  # Tests require downloading and launching Chromium
  doCheck = false;

  nativeBuildInputs = [ installShellFiles pkg-config python3];

  meta = with lib; {
    homepage = "https://github.com/simonw/rodney";
    description = "CLI tool for interacting with the web";
    mainProgram = "rodney";
    license = licenses.asl20;
  };
}
