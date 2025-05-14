{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-groq";
  version = "0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "angerman";
    repo = "llm-groq";
    rev = "v${version}";
    hash = "sha256-sZ5d9w43NvypaPrebwZ5BLgRaCHAhd7gBU6uHEdUaF4=";
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
