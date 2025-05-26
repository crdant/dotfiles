{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mbta-mcp-server";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "crdant";
    repo = "mbta-mcp-server";
    rev = "v${version}";
    hash = "sha256-eG6hOkZQY5NAEtVk+2qGCv/1wCQCiATeMbGU/kMyG6Q="; 
  };

  subPackages = [ "./cmd/server" ];

  vendorHash = "sha256-oUblXQWXZ4Y0mCkfkL/BpIgsatLcuAElXKAMuNDS3YY="; 

  buildPhase = ''
    export HOME=$(pwd)
    runHook preBuild
    make build
    runHook postBuild
  '';

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/mbta-mcp-server $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "MBTA MCP Server";
    homepage = "https://github.com/crdant/mbta-mcp-server";
    license = licenses.mit;
    maintainers = [ 
      maintainers.crdant
    ];
  };
}
