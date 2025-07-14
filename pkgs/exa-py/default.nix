# ./exa-py/default.nix
{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "exa-py";
  version = "1.14.6";


  pyproject = true;
  build-system = [ 
    python3.pkgs.setuptools
  ];
  
  src = fetchFromGitHub {
    owner = "exa-labs";
    repo = "exa-py";
    rev = "c7d4e5b830b3f934269e2c1cbda0f51644e3493a";
    sha256 = "sha256-VVJHhlE85w7RHbEYfw1MXva4Ktt3KU1OCWGHqp10fPk=";
  };

  # Runtime dependencies (from [project.dependencies] or [tool.poetry.dependencies])
  propagatedBuildInputs = with python3.pkgs; [
    requests
    typing-extensions
    openai
    pydantic
    httpx
  ];

  # Build-time dependencies (from [build-system.requires])
  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  # Test dependencies (from [tool.poetry.group.dev.dependencies])
  nativeCheckInputs = with python3.pkgs; [
    pytest
    pytest-cov
    pytest-mock
  ];

  # Other dev dependencies that aren't needed for building/testing
  # (like python-dotenv, setuptools, docutils, twine, datamodel-code-generator)
  # are typically omitted unless specifically needed

  pythonImportsCheck = [ "exa_py" ];  # Adjust module name as needed

  meta = with lib; {
    description = "Python SDK for Exa API";
    homepage = "https://github.com/exa-labs/exa-py";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
