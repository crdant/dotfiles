{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "mods";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = "v${version}";
    sha256 = "sha256-Niap2qsIJwlDRITkPD2Z7NCiJubkyy8/pvagj5Beq84=";
  };

  vendorHash = "sha256-DaSbmu1P/umOAhG901aC+TKa3xXSvUbpYsaiYTr2RJs=";

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
