# ./ttok/default.nix
{
  lib,
  python3,
  fetchFromGitHub,
  nix-update-script,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "ttok";
  version = "1.0";

  pyproject = true;
  build-system = [
    python3.pkgs.uv-build
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.11.0,<0.12.0' 'uv_build'
  '';

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "ttok";
    rev = version;
    sha256 = "sha256-VnslA5tYcrKLZJOXJi3ze/zhPyghBUlbuf6xpCDezgM=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    click
    tiktoken
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest
  ];

  pythonImportsCheck = [ "ttok" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Count and truncate text based on tokens";
    homepage = "https://github.com/simonw/ttok";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
