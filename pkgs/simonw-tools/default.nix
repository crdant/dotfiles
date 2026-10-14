# simonw tools, installed from the versions and hashes pinned in uv.lock.
# showboat and rodney are Go programs, but simonw publishes them to PyPI as
# platform wheels, so the same lockfile covers them.
{ pkgs, inputs }:
let
  inherit (pkgs) lib;
  inherit (inputs) pyproject-nix uv2nix pyproject-build-systems;

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {
    python = pkgs.python3;
  }).overrideScope (lib.composeManyExtensions [
    pyproject-build-systems.overlays.wheel
    (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
  ]);

  venv = pythonSet.mkVirtualEnv "simonw-tools-env" workspace.deps.default;

  # Expose only each tool's own commands, not its dependencies' scripts
  inherit (pkgs.callPackage pyproject-nix.build.util { }) mkApplication;
  app = name: mkApplication { inherit venv; package = pythonSet.${name}; };
in
lib.genAttrs [ "claude-code-transcripts" "rodney" "showboat" "ttok" ] app
