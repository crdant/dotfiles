{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "mods";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = "v${version}";
    sha256 = "sha256-wzLYkcgUWPzghJEhYRh7HH19Rqov1RJAxdgp3AGnOTY=";
  };

  vendorHash = "sha256-L+4vkh7u6uMm5ICMk8ke5RVY1oYeKMYWVYYq9YqpKiw=";

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
