{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-groq";
  version = "0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "angerman";
    repo = "llm-groq";
    rev = "57be10aeb6f69b31b067060209688982c409dd51";
    hash = "sha256-N2VbcY8z7AppZe0X0sk/cKTvb+WlMmWBtTkoLamtKSM=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    groq
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
    "llm_groq"
  ];

  meta = {
    description = "LLM access to models hosted by Groq";
    homepage = "https://github.com/angerman/llm-groq";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-groq";
  };
}
