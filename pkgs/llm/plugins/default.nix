# default.nix
{ lib, callPackage, python3Packages, stdenv }:

let
  # Import generated plugins
  generatedPlugins = callPackage ./generated-plugins.nix {};
  
  # Manual/custom plugins can go here
  customPlugins = {
    # Example custom plugin
    # my-custom-llm-plugin = callPackage ./custom-plugins/my-plugin.nix {};
  };

  # Filter plugins based on platform support
  supportedPlugins = lib.filterAttrs (name: plugin: 
    # If the plugin has a meta.broken attribute, filter it out
    !(plugin.meta.broken or false)
  ) generatedPlugins;

in

supportedPlugins // customPlugins // {
  # Utility functions for working with plugins
  
  # Get all plugins supported on current platform
  allSupported = lib.attrValues supportedPlugins;
  
  # Get all plugin names
  allNames = lib.attrNames supportedPlugins;
  
  # Get platform-specific plugins
  darwinOnly = lib.filterAttrs (name: plugin:
    lib.elem "darwin" (plugin.meta.platforms or [])
  ) supportedPlugins;
  
  linuxOnly = lib.filterAttrs (name: plugin:
    lib.elem "linux" (plugin.meta.platforms or [])
  ) supportedPlugins;
  
  # Utility function to create a wrapped LLM with plugins
  withPlugins = pluginList: 
    let
      # Filter out any broken/unsupported plugins from the list
      validPlugins = builtins.filter (plugin: !(plugin.meta.broken or false)) pluginList;
      
      llmWithPlugins = python3Packages.buildPythonPackage rec {
        pname = "llm-with-plugins";
        version = "combined";
        format = "other";
        
        dontUnpack = true;
        dontBuild = true;
        
        propagatedBuildInputs = [ 
          python3Packages.llm
        ] ++ validPlugins;
        
        installPhase = ''
          mkdir -p $out
          # Create a meta-package that just pulls in dependencies
        '';
        
        meta = with lib; {
          description = "LLM CLI with selected plugins";
          platforms = platforms.unix;
        };
      };
    in llmWithPlugins;
  
  # Utility function to create a shell script wrapper
  withPluginsScript = pluginList:
    let
      pythonEnv = python3Packages.python.withPackages (ps: [ ps.llm ] ++ pluginList);
    in stdenv.mkDerivation {
      name = "llm-with-plugins";
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/llm << 'EOF'
        #!${stdenv.shell}
        exec ${pythonEnv}/bin/llm "$@"
        EOF
        chmod +x $out/bin/llm
      '';
      meta = with lib; {
        description = "LLM CLI with plugins wrapper script";
        platforms = platforms.unix;
      };
    };
}