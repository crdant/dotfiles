{ lib, pkgs, python3Packages }:

let
  inherit (python3Packages) buildPythonPackage;

  generatedPlugins = import ./generated.nix {
    inherit lib buildPythonPackage;
    inherit (pkgs) fetchzip llm;
  };

  plugins = generatedPlugins;

in plugins // {
  inherit plugins;
  
  withPlugins = llmPlugins: pkgs.llm.override {
    withPlugins = _: map (name: plugins.${"llmPlugin.${name}"}) llmPlugins;
  };
}
