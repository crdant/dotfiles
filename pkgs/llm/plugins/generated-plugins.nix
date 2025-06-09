# This file is generated automatically. Do not edit manually.
# Update with: python3 update-plugins.py

{ lib, callPackage, fetchFromGitHub, python3Packages, stdenv }:

let
  buildLlmPlugin = callPackage ./build-llm-plugin.nix {};
in
{
  llm-anthropic = buildLlmPlugin {
    pname = "llm-anthropic";
    version = "ref-0.17";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-anthropic";
      rev = "0.17";
      sha256 = "sha256-2fatBKZMttC5flzfC7MWCpduc3m6IOVWZiW1K2dYqis=";
    };
    description = "LLM access to models by Anthropic, including the Claude series";
    pythonDeps = ["anthropic"];
  };

  llm-clip = buildLlmPlugin {
    pname = "llm-clip";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-clip";
      rev = "0.1";
      sha256 = "sha256-QeX8YBees4W8RdBuYrRX2iv93otXIsUEmfMd914wVfo=";
    };
    description = "Provides the CLIP model for embedding images and text";
    pythonDeps = ["sentence-transformers"];
  };

  llm-cmd = buildLlmPlugin {
    pname = "llm-cmd";
    version = "ref-0.2a0";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-cmd";
      rev = "0.2a0";
      sha256 = "sha256-RhwQEllpee/XP1p0nrgL4m+KjSZzf61J8l1jJGlg94E=";
    };
    description = "Accepts a prompt for a shell command, runs that prompt";
    pythonDeps = ["prompt_toolkit" "pygments"];
  };

  llm-command-r = buildLlmPlugin {
    pname = "llm-command-r";
    version = "ref-0.3.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-command-r";
      rev = "0.3.1";
      sha256 = "sha256-PxICRds9NJQP64HwoL7Oxd39yaIrMdAyQEbhaumJCgo=";
    };
    description = "Cohere's Command R models";
    pythonDeps = ["cohere"];
  };

  llm-echo = buildLlmPlugin {
    pname = "llm-echo";
    version = "ref-0.3a3";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-echo";
      rev = "0.3a3";
      sha256 = "sha256-4345UIyaQx+mYYBAFD5AaX5YbjbnJQt8bKMD5Vl8VJc=";
    };
    description = "Debug plugin for LLM providing an echo model";
    pythonDeps = [];
  };

  llm-embed-jina = buildLlmPlugin {
    pname = "llm-embed-jina";
    version = "ref-0.1.2";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-embed-jina";
      rev = "0.1.2";
      sha256 = "sha256-L9gZ5Phg00oK9cczmXMgP4FRhSvon8b2TmcI/cLPwcg=";
    };
    description = "Provides Jina AI's 8K text embedding models";
    pythonDeps = ["transformers" "torch"];
  };

  llm-fireworks = buildLlmPlugin {
    pname = "llm-fireworks";
    version = "ref-0.1a0";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-fireworks";
      rev = "0.1a0";
      sha256 = "sha256-gHSEVs17dAvRYmlvZ90DtdSF69FY23c5gVrPCBn0dto=";
    };
    description = "Access fireworks.ai models via API";
    pythonDeps = [];
  };

  llm-gemini = buildLlmPlugin {
    pname = "llm-gemini";
    version = "ref-0.22";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-gemini";
      rev = "0.22";
      sha256 = "sha256-8zUOP+LNwdUXx4hR3m5lodcVUmB4ZjyiWqWzk2tV9wM=";
    };
    description = "LLM plugin to access Google's Gemini family of models";
    pythonDeps = ["httpx" "ijson"];
  };

  llm-gguf = buildLlmPlugin {
    pname = "llm-gguf";
    version = "ref-0.2";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-gguf";
      rev = "0.2";
      sha256 = "sha256-ihMOiQnTfgZKICVDoQHLOMahrd+GiB+HwWFBMyIcs0A=";
    };
    description = "Uses llama.cpp to run models in GGUF format";
    pythonDeps = ["httpx" "llama-cpp-python"];
  };

  llm-gpt4all = buildLlmPlugin {
    pname = "llm-gpt4all";
    version = "ref-0.4";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-gpt4all";
      rev = "0.4";
      sha256 = "sha256-+UthXEk2BPD8CqQp6yqyIAd9DmFrZ2xx+ySg9t3c9k4=";
    };
    description = "Support for GPT4All locally optimized models";
    pythonDeps = ["gpt4all" "httpx"];
  };

  llm-groq = buildLlmPlugin {
    pname = "llm-groq";
    version = "0.8";
    src = fetchFromGitHub {
      owner = "angerman";
      repo = "llm-groq";
      rev = "v0.8";
      sha256 = "sha256-sZ5d9w43NvypaPrebwZ5BLgRaCHAhd7gBU6uHEdUaF4=";
    };
    description = "LLM access to models hosted by Groq";
    pythonDeps = ["groq"];
  };

  llm-llamafile = buildLlmPlugin {
    pname = "llm-llamafile";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-llamafile";
      rev = "0.1";
      sha256 = "sha256-LF1LhKgi7Pm1cRpFweyawDqXiDwfexa37HtpgOs6JoQ=";
    };
    description = "Support for local models using llamafile";
    pythonDeps = [];
  };

  llm-mistral = buildLlmPlugin {
    pname = "llm-mistral";
    version = "ref-0.14";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-mistral";
      rev = "0.14";
      sha256 = "sha256-NuiqRA/SCjGq0hJsnHJ/vgdncIKu3oE9WqWGht7QRMc=";
    };
    description = "Mistral AI language and embedding models";
    pythonDeps = ["httpx" "httpx-sse"];
  };

  llm-mlc = buildLlmPlugin {
    pname = "llm-mlc";
    version = "ref-0.5";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-mlc";
      rev = "0.5";
      sha256 = "sha256-OZUDEh1rt995BIiB7i2AjmFHRcd7Ls24FQSVJI8r/k8=";
    };
    description = "Runs MLC project models, optimized for Apple Silicon";
    pythonDeps = ["httpx"];
  };

  llm-mlx = buildLlmPlugin {
    pname = "llm-mlx";
    version = "ref-0.4";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-mlx";
      rev = "0.4";
      sha256 = "sha256-9SGbvhuNeKgMYGa0ZiOLm+H/JbNpvFWBcUL4De5xO4o=";
    };
    description = "Support for MLX models in LLM";
    pythonDeps = ["mlx-lm"];
    platformSpecific = {
    darwin = {
    aarch64 = true;
  };
  };
  };

  llm-mpt30b = buildLlmPlugin {
    pname = "llm-mpt30b";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-mpt30b";
      rev = "0.1";
      sha256 = "sha256-LgaKgYyxBiP0SJr0BR8XIrz9K0hf+emK5ycSGxUIdfQ=";
    };
    description = "Support for MPT-30B local model";
    pythonDeps = ["ctransformers" "transformers" "huggingface-hub"];
  };

  llm-ollama = buildLlmPlugin {
    pname = "llm-ollama";
    version = "ref-0.11.0";
    src = fetchFromGitHub {
      owner = "taketwo";
      repo = "llm-ollama";
      rev = "0.11.0";
      sha256 = "sha256-iwrDqrPt/zwXypBwD7zDAcen4fQq6PXl7Xj5VUL2KWA=";
    };
    description = "Support for local models via Ollama";
    pythonDeps = ["ollama" "pydantic"];
  };

  llm-perplexity = buildLlmPlugin {
    pname = "llm-perplexity";
    version = "ref-2025.6.0";
    src = fetchFromGitHub {
      owner = "hex";
      repo = "llm-perplexity";
      rev = "2025.6.0";
      sha256 = "sha256-LTf2TY5bjSb7ARXrhWj1ctGuMpnq2Kl/kv/hrgX/m/M=";
    };
    description = "LLM access to pplx-api";
    pythonDeps = ["openai"];
  };

  llm-python = buildLlmPlugin {
    pname = "llm-python";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-python";
      rev = "0.1";
      sha256 = "sha256-Z991f0AGO5iaCeoG9dkFhTLtuR45PgCS9awCvOAuPPs=";
    };
    description = "Adds a 'llm python' command for running a Python interpreter";
    pythonDeps = [];
  };

  llm-reka = buildLlmPlugin {
    pname = "llm-reka";
    version = "ref-0.1a0";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-reka";
      rev = "0.1a0";
      sha256 = "sha256-f2z61DyqOwFj0pw15SuMqhC0rMXhKEgID0NEOy6Hz4c=";
    };
    description = "Reka family of models";
    pythonDeps = ["reka-api"];
  };

  llm-sentence-transformers = buildLlmPlugin {
    pname = "llm-sentence-transformers";
    version = "ref-0.3.2";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-sentence-transformers";
      rev = "0.3.2";
      sha256 = "sha256-FDDMItKFEYEptiL3EHKgKVxClqRU9RaM3uD3xP0F4OM=";
    };
    description = "Adds support for embeddings using the sentence-transformers library";
    pythonDeps = ["sentence-transformers" "einops"];
  };

  llm-tools-datasette = buildLlmPlugin {
    pname = "llm-tools-datasette";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-tools-datasette";
      rev = "0.1";
      sha256 = "sha256-Us9bPk2qpTlgJqQ0Cl9QdeqW+h8j+pmnkriM0WXEyyA=";
    };
    description = "Can run SQL queries against a remote Datasette instance";
    pythonDeps = [];
  };

  llm-tools-exa = buildLlmPlugin {
    pname = "llm-tools-exa";
    version = "ref-0.4.0";
    src = fetchFromGitHub {
      owner = "daturkel";
      repo = "llm-tools-exa";
      rev = "0.4.0";
      sha256 = "sha256-dEpABHyfZuBft8SQUhSaJuaNfAtbI5zyJwr7nb84akM=";
    };
    description = "Can perform web searches and question-answering using exa.ai";
    pythonDeps = ["exa-py"];
  };

  llm-tools-quickjs = buildLlmPlugin {
    pname = "llm-tools-quickjs";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-tools-quickjs";
      rev = "0.1";
      sha256 = "sha256-Si3VcHnRUj8Q/N8pRhltPOM6K64TX9DBH/u4WQxQJjQ=";
    };
    description = "Provides access to a sandboxed QuickJS JavaScript interpreter";
    pythonDeps = ["quickjs"];
  };

  llm-tools-simpleeval = buildLlmPlugin {
    pname = "llm-tools-simpleeval";
    version = "ref-0.1.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-tools-simpleeval";
      rev = "0.1.1";
      sha256 = "sha256-IOmYu7zoim7Co/xIm5VLaGkCPI0o+2Nb2Pu3U2fH0BU=";
    };
    description = "Implements simple expression support for things like mathematics";
    pythonDeps = ["simpleeval"];
  };

  llm-tools-sqlite = buildLlmPlugin {
    pname = "llm-tools-sqlite";
    version = "ref-0.1";
    src = fetchFromGitHub {
      owner = "simonw";
      repo = "llm-tools-sqlite";
      rev = "0.1";
      sha256 = "sha256-VAmK4cXzZWTWCU92TwMdhNJPvYPZ88t5BZe8vo60SZY=";
    };
    description = "Can run read-only SQL queries against local SQLite databases";
    pythonDeps = [];
  };

}
