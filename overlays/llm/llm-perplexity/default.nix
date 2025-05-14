{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-perplexity";
  version = "2025.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hex";
    repo = "llm-perplexity";
    rev = version;
    hash = "sha256-MM4x9I7c8Ghkxm+fpVRyFPMjkzdm4cDjVxErZcXlVdU=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    llm
    openai
  ];

  pythonImportsCheck = [
    "llm_perplexity"
  ];

  meta = {
    description = "LLM access to pplx-api";
    homepage = "https://github.com/hex/llm-perplexity";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-perplexity";
  };
}
