{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "leftovers";
  version = "0.70.0";

  src = fetchFromGitHub {
    owner = "genevieve";
    repo = "leftovers";
    rev = "v0.70.0";
    sha256 = "sha256-Vehs4IbAjqNIJiQ1d7KGS6N66PloigalufxThkNJz+E=";
  };

  vendorHash = "sha256-yYRQcjQyVqoBUkWHG/hwuSK/JLsl6u+wrGAuWOxwIAs=";

  nativeBuildInputs = [ installShellFiles ];

  meta = with lib; {
    homepage = "https://github.com/genevieve/leftovers";
    description = "Go cli for cleaning up orphaned IAAS resources.";
    mainProgram = "leftovers";
    license = licenses.mit;
  };
}

