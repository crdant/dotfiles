{
  lib,
  python3,
  fetchFromGitHub,
  nix-update-script,
  playwright-driver,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "shot-scraper";
  version = "1.12";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "shot-scraper";
    rev = version;
    sha256 = "sha256-6Ab8BsxBxPnNS1728rQ3R8lH4Al+DJnnG5Kx0zYZ7OY=";
  };

  # Upstream pins uv_build below 0.10, but nixpkgs ships a newer one
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.9.18,<0.10.0' 'uv_build'
  '';

  build-system = [
    python3.pkgs.uv-build
  ];

  dependencies = with python3.pkgs; [
    click
    click-default-group
    playwright
    pydantic
    pyyaml
  ];

  # Point Playwright at the browsers nixpkgs builds alongside it, so
  # `shot-scraper install` isn't needed and the revisions always match
  makeWrapperArgs = [
    "--set-default" "PLAYWRIGHT_BROWSERS_PATH" "${playwright-driver.browsers}"
  ];

  # Tests drive a real browser, which isn't available in the sandbox
  doCheck = false;

  pythonImportsCheck = [ "shot_scraper" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Tool for taking automated screenshots of websites";
    homepage = "https://github.com/simonw/shot-scraper";
    license = licenses.asl20;
    mainProgram = "shot-scraper";
    maintainers = with maintainers; [ ];
  };
}
