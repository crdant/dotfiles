{ stdenv, lib, buildGoModule, fetchzip, installShellFiles }:
let
  os = if stdenv.isDarwin then "darwin" else "linux" ;
  arch = if stdenv.isAarch64 then "arm64" else "amd64";

  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in stdenv.mkDerivation rec {
  pname = "troubeleshoot-sbctl";
  version = "0.17.0";

  src = fetchzip {
    url = "https://github.com/replicatedhq/sbctl/releases/download/v${version}/sbctl_${os}_${arch}.tar.gz";
    stripRoot = false;
    sha256 = if isDarwin then
        "sha256-riJyiKMdxpX5MckdOex8TA1Cu2W9Gt7Bw+O+8ILFDj4="
      else
        "";
  };

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 sbctl $out/bin/sbctl
    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/sbctl completion bash > sbctl.bash
    $out/bin/sbctl completion zsh > sbctl.zsh
    $out/bin/sbctl completion fish > sbctl.fish
    installShellCompletion sbctl.{bash,zsh,fish}
  '';

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/sbctl";
    description = "Command line tool for examining K8s resources in Troubleshoot's support bundles";
    mainProgram = "sbctl";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
  };

}
