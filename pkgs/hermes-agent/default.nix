{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "hermes-agent";
  version = "0.14.0";
  pyproject = true;

  src = fetchPypi {
    pname = "hermes_agent";
    inherit version;
    hash = "sha256-jy8UElmQswXqtOKcI+GAORgFy4GxHXs9o4RH4pCV2ks=";
  };

  # The package pins exact versions as a supply-chain security measure.
  # Nix provides its own reproducibility guarantees, so we relax the
  # pins and use the versions that nixpkgs provides.
  pythonRelaxDeps = true;

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  dependencies = with python3.pkgs; [
    openai
    python-dotenv
    fire
    httpx
    socksio   # provides httpx[socks]
    rich
    tenacity
    pyyaml
    ruamel-yaml
    requests
    jinja2
    pydantic
    prompt-toolkit
    croniter
    pyjwt
    cryptography  # provides pyjwt[crypto]
    psutil
  ];

  # No test suite to run at build time
  doCheck = false;

  meta = with lib; {
    description = "Self-improving AI agent by Nous Research";
    homepage = "https://github.com/NousResearch/hermes-agent";
    license = licenses.mit;
    mainProgram = "hermes";
  };
}
