{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "kots";
  version = "1.108.0";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "kots";
    rev = "v${version}";
    sha256 = "sha256-STsqo0ME8T8SiIT/2e6XdT70JOkUQ2hhsY7FrifFdJY=";
  };

  vendorHash = "sha256-h7jLeWWcDAeF5n0pHLjHfJLLWwtw40940CxMnSwrJEk=";

  subPackages = [ "cmd/kots/" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/kubectl-kots completion bash > kubectl-kots.bash
    $out/bin/kubectl-kots completion zsh > kubectl-kots.zsh
    $out/bin/kubectl-kots completion fish > kubectl-kots.fish
    installShellCompletion kubectl-kots.{bash,zsh,fish}
  '';

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/kots";
    description = "KOTS provides the framework, tools and integrations that enable the delivery and management of 3rd-party Kubernetes applications, a.k.a. Kubernetes Off-The-Shelf (KOTS) Software.";
    mainProgram = "kubectl-kots";
    license = licenses.asl20;
  };
}
