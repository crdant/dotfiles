# ./mlx-lm/default.nix
{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "mlx-lm";  # Note: using underscore in pname as it appears on PyPI
  version = "0.24.1";  # Updated to the latest version
  format = "wheel";
  
  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    python = "py3";
    dist = "py3";
    platform = "any";
    sha256 = ""; 
  };
  
  # Add required dependencies
  propagatedBuildInputs = with python3.pkgs; [
    # List dependencies here
    # You might need to check the package metadata for actual dependencies
    mlx
  ];
  
  doCheck = false;
  pythonImportsCheck = [ "mlx_lm" ];
  
  meta = {
    description = "MLX language models for Apple Silicon";
    homepage = "https://pypi.org/project/mlx/";
    license = lib.licenses.mit;  # Update with the correct license
  };
}
