{ lib, pkgs, python3Packages }:

let
  inherit python3Packages ;

  generatedPlugins = import ./generated.nix {
    inherit lib python3Packages ;
    inherit (pkgs) fetchzip llm ;
  };

  plugins = generatedPlugins;

in plugins // {
  inherit plugins;
  
  withPlugins = llmPlugins: pkgs.llm.override {
    withPlugins = _: map (name: plugins.${"llmPlugin.${name}"}) llmPlugins;
  };
}
