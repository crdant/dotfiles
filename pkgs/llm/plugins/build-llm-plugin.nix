# build-llm-plugin.nix
{ pkgs, lib, fetchFromGitHub, stdenv }:

{ pname
, version
, src
, description ? ""
, pythonDeps ? []
, buildInputs ? []
, checkInputs ? []
, doCheck ? false
, platformSpecific ? {}
, meta ? {}
, ...
}@args:

let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    inherit (pkgs) system;
  };
  python3Packages = unstable.python3Packages;

  # Check if this plugin is supported on current platform
  isPlatformSupported = 
    if platformSpecific == {} then true
    else if stdenv.isDarwin && platformSpecific ? darwin then
      if platformSpecific.darwin ? aarch64 then
        (stdenv.isAarch64 == platformSpecific.darwin.aarch64)
      else if platformSpecific.darwin ? x86_64 then
        (stdenv.isx86_64 == platformSpecific.darwin.x86_64)
      else true
    else if stdenv.isLinux && platformSpecific ? linux then
      if platformSpecific.linux ? aarch64 then
        (stdenv.isAarch64 == platformSpecific.linux.aarch64)
      else if platformSpecific.linux ? x86_64 then
        (stdenv.isx86_64 == platformSpecific.linux.x86_64)
      else true
    else if platformSpecific ? any then
      platformSpecific.any
    else false;

  # Create a stub package for unsupported platforms
  stubPackage = python3Packages.buildPythonPackage {
    inherit pname version;
    format = "other";
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      echo "This package (${pname}) is not supported on this platform" > $out/README
    '';
    meta = {
      broken = true;
      description = "${description} (not supported on this platform)";
    } // (args.meta or {});
  };

in

if !isPlatformSupported then stubPackage else

python3Packages.buildPythonPackage (rec {
  inherit pname version src doCheck;
  pyproject = true;

  propagatedBuildInputs = with python3Packages; [
    # Always include the base llm package
    llm
  ] ++ (map (dep: 
    if python3Packages ? ${dep} then 
      python3Packages.${dep} 
    else 
      throw "Python package '${dep}' not found in python3Packages"
  ) pythonDeps);

  nativeBuildInputs = with python3Packages; [
    setuptools
    wheel
  ];

  inherit buildInputs checkInputs;

  # Most LLM plugins don't have comprehensive tests or require API keys
  # doCheck is already inherited above, so we don't redefine it here

  pythonImportsCheck = [ (builtins.replaceStrings ["-"] ["_"] pname) ];

  meta = with lib; {
    inherit description;
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.asl20;
    maintainers = with maintainers; [ /* your name here */ ];
    platforms = if platformSpecific != {} then
      (if platformSpecific ? darwin then platforms.darwin else []) ++
      (if platformSpecific ? linux then platforms.linux else []) ++
      (if platformSpecific ? any && platformSpecific.any then platforms.all else [])
    else platforms.unix;
  } // (args.meta or {});
} // (removeAttrs args [ "pname" "version" "src" "description" "pythonDeps" "buildInputs" "checkInputs" "doCheck" "meta" "platformSpecific" ]))
