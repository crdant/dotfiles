{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "helm-beta";
  version = "4.0.0-beta.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = "helm";
    rev = "v${version}";
    sha256 = "sha256-M/le8jY7i+Nqd6bPB4tvvOSQj1TFwOYdUy8N6klOLG4=";
  };

  vendorHash = "sha256-W1G0pX05tR4MfQfil8l4sYwWim7UdGGRI30dhZmphi8=";

  doCheck = false;

  subPackages = [ "cmd/helm" ];

  ldflags = [
    "-w"
    "-s"
    "-X helm.sh/helm/v3/internal/version.version=v${version}"
    "-X helm.sh/helm/v3/internal/version.gitCommit=${src.rev}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/helm completion bash > helm.bash
    $out/bin/helm completion zsh > helm.zsh
    $out/bin/helm completion fish > helm.fish
    installShellCompletion helm.{bash,zsh,fish}
  '';

  meta = with lib; {
    description = "Helm 4.0 Beta - Kubernetes package manager";
    homepage = "https://github.com/helm/helm";
    license = licenses.asl20;
    mainProgram = "helm";
    platforms = platforms.unix;
  };
}
