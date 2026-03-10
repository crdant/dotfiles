{ stdenv, lib, pkgs, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config, bash, python3 }:
let
  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in
buildGoModule rec {
  pname = "showboat";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "showboat";
    rev = "v${version}";
    sha256 = "sha256-yYK6j6j7OgLABHLOSKlzNnm2AWzM2Ig76RJypBsBnkI=";
  };

  vendorHash = "sha256-mGKxBRU5TPgdmiSx0DHEd0Ys8gsVD/YdBfbDdSVpC3U=";

  nativeBuildInputs = [ installShellFiles pkg-config python3 ];

  meta = with lib; {
    homepage = "https://github.com/simonw/showboat";
    description = "CLI tool for interacting with the web";
    mainProgram = "showboat";
    license = licenses.asl20;
  };
}
