{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-fireworks";
  version = "0.1a0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-fireworks";
    rev = version;
    hash = "sha256-gHSEVs17dAvRYmlvZ90DtdSF69FY23c5gVrPCBn0dto=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    llm
  ];

  pythonImportsCheck = [
    "llm_fireworks"
  ];

  meta = {
    description = "Access fireworks.ai models via API";
    homepage = "https://github.com/simonw/llm-fireworks";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-fireworks";
  };
}

