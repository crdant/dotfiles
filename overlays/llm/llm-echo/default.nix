
{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-echo";
  version = "0.3a3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-echo";
    rev = version;
    hash = "sha256-4345UIyaQx+mYYBAFD5AaX5YbjbnJQt8bKMD5Vl8VJc=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    llm
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      pytest
      pytest-asyncio
    ];
  };

  pythonImportsCheck = [
    "llm_echo"
  ];

  meta = {
    description = "Debug plugin for LLM providing an echo model";
    homepage = "https://github.com/simonw/llm-echo";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-echo";
  };
}
