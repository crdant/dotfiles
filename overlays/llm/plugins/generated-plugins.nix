# This file is generated automatically. Do not edit manually.
# Update with: python3 update-plugins.py

{ lib, callPackage, fetchFromGitHub, python3Packages, stdenv }:

let
  buildLlmPlugin = callPackage ./build-llm-plugin.nix {};
in
{
  llm-anthropic = buildLlmPlugin {
    pname = "llm-anthropic";
    version = "unstable-2025-05-27";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-anthropic";
      rev = "e72f1e52968801e10f6005c504c51bc00062d58e";
      sha256 = "0axab1kjpd95crbfa85sg5rnx5qa2srhppswgswx1djclq2avxnr";
    };
    description = "LLM access to models by Anthropic, including the Claude series";
    pythonDeps = ["anthropic"];
  };

  llm-echo = buildLlmPlugin {
    pname = "llm-echo";
    version = "unstable-2025-05-21";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-echo";
      rev = "6e8f7da62b34ec0e907a8a4bf91f6fac16cfb447";
      sha256 = "15slgicya0x3diy0n9g76rp5hzk980z18h40c6k1yhwsii83jzp3";
    };
    description = "Debug plugin for LLM providing an echo model";
    pythonDeps = [];
  };

  llm-fireworks = buildLlmPlugin {
    pname = "llm-fireworks";
    version = "unstable-2024-04-18";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-fireworks";
      rev = "d221f15584e646fdf933df6afe083316eaadf310";
      sha256 = "1nknyhchikssh4wpgnsqs7mqbm5m0gfnfvv9cb8hnx3vrmb88x40";
    };
    description = "Access fireworks.ai models via API";
    pythonDeps = [];
  };

  llm-gemini = buildLlmPlugin {
    pname = "llm-gemini";
    version = "unstable-2025-06-05";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-gemini";
      rev = "c17e21abd4b230bb4645396e60f96baa9eefb2f5";
      sha256 = "00zpammr7cx5bai3qrkqc191bmx1cmpdwlc8qwbxbhfdw8zhwdgk";
    };
    description = "LLM plugin to access Google's Gemini family of models";
    pythonDeps = ["httpx" "ijson"];
  };

  llm-groq = buildLlmPlugin {
    pname = "llm-groq";
    version = "unstable-2025-01-30";
    src = fetchFromGitHub {
      owner = "angerman";
      repo = "llm-groq";
      rev = "f7335e34db4bce9784bb010ca6e773e4f317b59c";
      sha256 = "0pk8ai3irbjf0phdx1f045l13f04g436zppsd2lzqdip1vvmv7mi";
    };
    description = "LLM access to models hosted by Groq";
    pythonDeps = ["groq"];
  };

  llm-mlx = buildLlmPlugin {
    pname = "llm-mlx";
    version = "unstable-2025-04-23";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-mlx";
      rev = "b477833b807143241220f6561742833070d907cc";
      sha256 = "12ivf7p0vy22f60mbg39ncjzzqcvicindd36c06ahy4d3fz9n8gm";
    };
    description = "Support for MLX models in LLM";
    pythonDeps = ["mlx-lm"];
    platformSpecific = {
    darwin = {
    aarch64 = true;
  };
  };
  };

  llm-perplexity = buildLlmPlugin {
    pname = "llm-perplexity";
    version = "unstable-2025-06-04";
    src = fetchFromGitHub {
      owner = "hex";
      repo = "llm-perplexity";
      rev = "05f1a677cc76791dc998c8dc16b9345d2b041873";
      sha256 = "1wwvzw2sxqgzj9zskn7ak4raxlbjyml8bsqm07xjd3avir6zcdrd";
    };
    description = "LLM access to pplx-api";
    pythonDeps = ["openai"];
  };

}
