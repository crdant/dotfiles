{
  lib,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "obsidian-headless";
  version = "0.0.14";

  src = ./.;

  npmDepsHash = "sha256-BfccB+FZgHt07hMdlXxEDcjo1zMVgXgJlX5BLgnopps=";
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/obsidian-headless-wrapper/node_modules/.bin/ob $out/bin/ob
  '';

  meta = with lib; {
    description = "Headless CLI client for Obsidian Sync and Publish";
    homepage = "https://obsidian.md/help/headless";
    license = licenses.unfree;
    mainProgram = "ob";
  };
}
