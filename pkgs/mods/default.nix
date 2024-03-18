{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "mods";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = "v${version}";
    sha256 = "sha256-ecmfWnrd9gwIEGAOIcOeUnfmkKmq9dLxpKqAHJemhvU=";
  };

  vendorHash = "sha256-pJ31Lsa5VVix3BM4RrllQA3MJ/JeNIKfQ8RClyFfXCI=";

  # nativeBuildInputs = [ installShellFiles pkg-config ];

  # postInstall = ''
  #   $out/bin/kubectl-kots completion bash > kubectl-kots.bash
  #   $out/bin/kubectl-kots completion zsh > kubectl-kots.zsh
  #   $out/bin/kubectl-kots completion fish > kubectl-kots.fish
  #   installShellCompletion kubectl-kots.{bash,zsh,fish}
  # '';

  meta = with lib; {
    homepage = "https://github.com/charmbracelet/mods";
    description = "AI on the command line";
    mainProgram = "mods";
    license = licenses.mit;
  };
}
