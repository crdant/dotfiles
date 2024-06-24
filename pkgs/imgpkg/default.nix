{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "imgpkg";
  version = "0.42.2";

  src = fetchFromGitHub {
    owner = "carvel-dev";
    repo = "imgpkg";
    rev = "v${version}";
    sha256 = "sha256-YpMAlFmSSXQYgPpkc9diIyAdJcglU66841tBDHE5VSQ=";
  };

  vendorHash = null;

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X github.com/carvel-dev/imgpkg/pkg/imgpkg/cmd/version.Version=${version}"
  ];

  subPackages = [ "cmd/imgpkg" ];

  postInstall = ''
    installShellCompletion --cmd imgpkg \
      --bash <($out/bin/imgpkg completion bash) \
      --fish <($out/bin/imgpkg completion fish) \
      --zsh <($out/bin/imgpkg completion zsh)
  '';

  meta = with lib; {
    description = "Store application configuration files in Docker/OCI registries";
    mainProgram = "imgpkg";
    homepage = "https://carvel.dev/imgpkg";
    license = licenses.asl20;
  };
}
