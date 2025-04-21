{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "condense-json";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "condense-json";
    rev = version;
    hash = "sha256-eZ8d8N7k8VL7dFkORHmp7JmHM1/11Km8BCriWw/LiwE=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      cogapp
      pytest
      pytest-asyncio
      pytest-recording
    ];
  };

  pythonImportsCheck = [
    "condense_json"
  ];

  meta = {
    description = "Python function for condensing JSON using replacement strings";
    homepage = "https://github.com/simonw/condense-json";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
