{ stdenv, lib, buildGoModule, fetchFromGitHub, nix-update-script, installShellFiles, pkg-config }:

buildGoModule rec {
  pname = "tunnelmanager";
  version = "0-unstable-2024-01-12";

  src = fetchFromGitHub {
    owner = "crdant";
    repo = "tunnelmanager";
    rev = "7190a4432d4cf820384f004920573d4b948712b8";
    sha256 = "sha256-v36xjjkukY9EXHLp9/z/YUysMCA+NXIWr9B+37UODiQ=";
  };

  vendorHash = "sha256-eKeUhS2puz6ALb+cQKl7+DGvm9Cl+miZAHX0imf9wdg=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/tunnelctl completion bash > tunnelctl.bash
    $out/bin/tunnelctl completion zsh > tunnelctl.zsh
    $out/bin/tunnelctl completion fish > tunnelctl.fish
    installShellCompletion tunnelctl.{bash,zsh,fish}
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    homepage = "https://github.com/crdant/tunnelmanager";
    description = "Simple SSH tunnel manager since I always forget the arguments";
    mainProgram = "tunnelctl";
    license = licenses.mit;
  };
}
