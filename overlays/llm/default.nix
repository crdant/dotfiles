# Generated LLM plugins overlay
# This overlay provides all LLM plugins as top-level packages

final: prev: {
  llmPlugins = final.callPackage ./plugins/generated-plugins.nix {};
  
  # Individual plugins available at top level
  llm-anthropic = final.llmPlugins.llm-anthropic;
  llm-echo = final.llmPlugins.llm-echo;
  llm-fireworks = final.llmPlugins.llm-fireworks;
  llm-gemini = final.llmPlugins.llm-gemini;
  llm-groq = final.llmPlugins.llm-groq;
  llm-mlx = final.llmPlugins.llm-mlx;
  llm-perplexity = final.llmPlugins.llm-perplexity;

  # Convenience function to create LLM with selected plugins
  llmWithPlugins = pluginList: 
    let
      pythonEnv = final.python3.withPackages (ps: [ ps.llm ] ++ pluginList);
    in final.writeShellScriptBin "llm" ''
      exec ${pythonEnv}/bin/llm "$@"
    '';
}
