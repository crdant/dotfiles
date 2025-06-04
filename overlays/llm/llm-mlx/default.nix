{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "llm-mlx";
  version = "0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-mlx";
    rev = version;
    hash = "sha256-9SGbvhuNeKgMYGa0ZiOLm+H/JbNpvFWBcUL4De5xO4o=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    llm
    mlx-lm
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      pytest
    ];
  };

  pythonImportsCheck = [
    "llm_mlx"
  ];

  meta = {
    description = "Support for MLX models in LLM";
    homepage = "https://github.com/simonw/llm-mlx";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-mlx";
  };
}
