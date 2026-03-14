{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "claude-code-transcripts";
  version = "0.6";

  pyproject = true;
  build-system = [
    python3.pkgs.uv-build
  ];

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "claude-code-transcripts";
    rev = version;
    hash = "sha256-MCs8B00K/D4rO4kWi3PlATo44rvBlQWYF7gU2c5tFrk=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    click
    click-default-group
    httpx
    jinja2
    markdown
    questionary
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest
  ];

  pythonImportsCheck = [ "claude_code_transcripts" ];

  meta = with lib; {
    description = "Convert Claude Code session files to HTML transcripts";
    homepage = "https://github.com/simonw/claude-code-transcripts";
    license = licenses.asl20;
    mainProgram = "claude-code-transcripts";
  };
}
