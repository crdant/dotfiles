{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-anthropic";
  version = "0.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-anthropic";
    rev = version;
    hash = "sha256-2fatBKZMttC5flzfC7MWCpduc3m6IOVWZiW1K2dYqis=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    anthropic
    llm
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
    "llm_anthropic"
  ];

  meta = {
    description = "LLM access to models by Anthropic, including the Claude series";
    homepage = "https://github.com/simonw/llm-anthropic";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-anthropic";
  };
}
