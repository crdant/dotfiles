# ./mlx-lm/default.nix
{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "mlx-lm";  # Note: using underscore in pname as it appears on PyPI
  version = "0.24.1";  # Updated to the latest version
  
  src = fetchFromGitHub {
    owner = "ml-explore";
    repo = "mlx-lm";
    rev = "v${version}";
    hash = "sha256-d//JUhvRpNde1+drWWYJ9lmkXi+buaa1zxDg4rQdt0o="; 
  };
  
  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  # Add required dependencies
  propagatedBuildInputs = with python3.pkgs; [
    # List dependencies here
    # You might need to check the package metadata for actual dependencies
    mlx
    numpy
    transformers
    sentencepiece
    protobuf
    pyyaml
    jinja2
    huggingface-hub
  ];
  
  pythonImportsCheck = [ "mlx_lm" ];
  
  meta = {
    description = "MLX language models for Apple Silicon";
    homepage = "https://pypi.org/project/mlx/";
    license = lib.licenses.mit;  # Update with the correct license
  };
}
