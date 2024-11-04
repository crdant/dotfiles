{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "mods";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = "v${version}";
    sha256 = "sha256-1Qx3P1q7zmrzNqmiivri0BxdEsRYgS1cOp17S44jRPI=";
  };

  vendorHash = "sha256-LarOXYkyhSCMXkD2G3/XYHnj5bDcL6nwWxlMAYy+9d8=";

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
