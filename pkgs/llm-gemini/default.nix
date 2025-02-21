{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "llm-gemini";
  version = "0.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-gemini";
    rev = version;
    hash = "sha256-xYtfIajEU1iqHvSPDLmg9lHEllcKpVYyUuNZUGNcccw=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    httpx
    ijson
    llm
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      nest-asyncio
      pytest
      pytest-recording
    ];
  };

  pythonImportsCheck = [
    "llm_gemini"
  ];

  meta = {
    description = "LLM plugin to access Google's Gemini family of models";
    homepage = "https://github.com/simonw/llm-gemini";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-gemini";
  };
}
