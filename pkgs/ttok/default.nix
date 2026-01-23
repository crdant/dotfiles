# ./ttok/default.nix
{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "ttok";
  version = "0.3";

  pyproject = true;
  build-system = [
    python3.pkgs.setuptools
  ];

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "ttok";
    rev = version;
    sha256 = "sha256-I6EPE6GDAiDM+FbxYzRW4Pml0wDA2wNP1y3pD3dg7Gg=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    click
    tiktoken
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest
  ];

  pythonImportsCheck = [ "ttok" ];

  meta = with lib; {
    description = "Count and truncate text based on tokens";
    homepage = "https://github.com/simonw/ttok";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
