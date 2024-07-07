{ lib, buildPythonPackage, fetchFromGitHub, llm }:
{

  anyscale-endpoints = buildPythonPackage rec {
    pname = "anyscale-endpoints";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0kgmzrrck2sah03gmx426bv4abr1nyy124yf35zw3syyv7qvxpvg";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for models hosted by Anyscale Endpoints";
      homepage = "https://github.com/simonw/llm-anyscale-endpoints";
    };
  };


  bedrock-anthropic = buildPythonPackage rec {
    pname = "bedrock-anthropic";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1qx978s3b4wvjpyizjzcaw5m89dgdm4q86hcmdqn3fm9ril7i9z9";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for Anthropic's Claude on AWS Bedrock";
      homepage = "https://github.com/sblakey/llm-bedrock-anthropic";
    };
  };


  bedrock-meta = buildPythonPackage rec {
    pname = "bedrock-meta";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "15qnggn1y8jkil1igjjn4gjvwxj18jp0hma4irv62ziifvl0vxwl";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for Meta Llama2 on AWS Bedrock";
      homepage = "https://github.com/flabat/llm-bedrock-meta";
    };
  };


  claude = buildPythonPackage rec {
    pname = "claude";
    version = "0.1.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "01k1j5w21982zrrxj76ylf9i2g361prcc4zf6mj7kh0iv26jfki4";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for Anthropic's Claude";
      homepage = "https://github.com/tomviner/llm-claude";
    };
  };


  claude-3 = buildPythonPackage rec {
    pname = "claude-3";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1iv4fwdbc33nwv2idnjxsazmixnkwkkn7dqv6y9pisxh0fpiyvzq";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM access to Claude 3 by Anthropic";
      homepage = "https://github.com/simonw/llm-claude-3";
    };
  };


  clip = buildPythonPackage rec {
    pname = "clip";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0zmvbm9290y4dsymvj1darr0ry4ail4g9nrh1i9hn5sm3bkyzmzw";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Generate embeddings for images and text using CLIP with LLM";
      homepage = "https://github.com/simonw/llm-clip";
    };
  };


  cluster = buildPythonPackage rec {
    pname = "cluster";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1hqkpxzq437srdpjpvdiwrf14in53zkgj9cn6ygljz15fhy4z8qa";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for clustering embeddings";
      homepage = "https://github.com/simonw/llm-cluster";
    };
  };


  cmd = buildPythonPackage rec {
    pname = "cmd";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0ry5v2n6js0wvhl6rrnyf0758307y8jnd7cjmxlf6wgzxncd5zm7";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Use LLM to generate and execute commands in your shell";
      homepage = "https://github.com/simonw/llm-cmd";
    };
  };


  cohere = buildPythonPackage rec {
    pname = "cohere";
    version = "0.9";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0vwyxm4zwnsp0cjac5bs7j4h0hqpc2byr6cxb7l5gyrj9pa8yqdb";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Plugin for LLM adding support for Cohere's Generate and Summarize models";
      homepage = "https://github.com/accudio/llm-cohere";
    };
  };


  command-r = buildPythonPackage rec {
    pname = "command-r";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0aj6z3arawlaj2mqdhh7r08bp6523py7k203c4jysdjr86m99l4m";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Access the Cohere Command R family of models";
      homepage = "https://github.com/simonw/llm-command-r";
    };
  };


  embed-jina = buildPythonPackage rec {
    pname = "embed-jina";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1gkz95dz5a2mg9h0gdqmfz365mbd979wbpl12y53ig9b94as7hl8";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Embedding models from Jina AI";
      homepage = "https://github.com/simonw/llm-embed-jina";
    };
  };


  embed-onnx = buildPythonPackage rec {
    pname = "embed-onnx";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1741md6cjiia48y5f7a7a29gpx6sfslp4fm64g8am4v1hz85w2kb";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Run embedding models using ONNX";
      homepage = "https://github.com/simonw/llm-embed-onnx";
    };
  };


  fireworks = buildPythonPackage rec {
    pname = "fireworks";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1hmn7zplb9a458rczw3jjr77j62sq66iljywd0vw8nz3hmw24bwp";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Access fireworks.ai models via API";
      homepage = "https://github.com/simonw/llm-fireworks";
    };
  };


  gemini = buildPythonPackage rec {
    pname = "gemini";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0d7n6rgxq21dl0fnnm8nwcb4f81fl87qni7dzlgp64yvm8g595x6";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin to access Google's Gemini family of models";
      homepage = "https://github.com/simonw/llm-gemini";
    };
  };


  gpt4all = buildPythonPackage rec {
    pname = "gpt4all";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "064m8x1wj3vkd96050m9423zrv9lnpba2i4rygvsi5ic6biwv55l";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Plugin for LLM adding support for GPT4ALL models";
      homepage = "https://github.com/simonw/llm-gpt4all";
    };
  };


  groq = buildPythonPackage rec {
    pname = "groq";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "15c6ih69gk8f7w2k56f10i5sb25w7bh4jlyd6rcpi0r3a5h0x306";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "None";
      homepage = "https://github.com/angerman/llm-groq";
    };
  };


  llama-cpp = buildPythonPackage rec {
    pname = "llama-cpp";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1ds6lzlhkmvidpbp0a3kxy2mkfkv2lfb5jgwmmma258j0n2vpx81";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for running models using llama.cpp";
      homepage = "https://github.com/simonw/llm-llama-cpp";
    };
  };


  llamafile = buildPythonPackage rec {
    pname = "llamafile";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0jbm5vki3ar01alqdj2afvyqwb47x0asmwa71civ7w8jmhffgzp7";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Access llamafile localhost models via LLM";
      homepage = "https://github.com/simonw/llm-llamafile";
    };
  };


  markov = buildPythonPackage rec {
    pname = "markov";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "18y35qva0jdhrxzisxmphp3sicix2zf7q27jbiqbrk9w8df3mzqx";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Plugin for LLM adding a Markov chain generating model";
      homepage = "https://github.com/simonw/llm-markov";
    };
  };


  mistral = buildPythonPackage rec {
    pname = "mistral";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0hv9rdjpjqgs4vlsyfyj24zcdwi91a4yz4m33gw0bd1hhcakdpwd";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin providing access to Mistral models busing the Mistral API";
      homepage = "https://github.com/simonw/llm-mistral";
    };
  };


  mlc = buildPythonPackage rec {
    pname = "mlc";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1h2pr74b08r5zzlyx6s2l4fqmfakb07wcjscv51fklc2w51y807q";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for running models using MLC";
      homepage = "https://github.com/simonw/llm-mlc";
    };
  };


  mpt30b = buildPythonPackage rec {
    pname = "mpt30b";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1wyafxlbars12wrqrvlqbk1msalj3xv9ywqwz90msz42ci2llln7";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Plugin for LLM adding support for the MPT-30B language model";
      homepage = "https://github.com/simonw/llm-mpt30b";
    };
  };


  ollama = buildPythonPackage rec {
    pname = "ollama";
    version = "0.1.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "15xfhzcrbjrwvwcdxi8av5ac78jg7lknhn8aa3983f2q3qdca4wy";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin providing access to local Ollama models";
      homepage = "https://github.com/taketwo/llm-ollama";
    };
  };


  openrouter = buildPythonPackage rec {
    pname = "openrouter";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1b1i7q9pk7cxz8dhy16167ad6nfpcqv7b2vlv8pzqy8i6s2gys5p";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for models hosted by OpenRouter";
      homepage = "https://github.com/simonw/llm-openrouter";
    };
  };


  palm = buildPythonPackage rec {
    pname = "palm";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0n0f4bxa5mh2fhmwcapw1gl1zk5pmxjy88slri4qx2rkw9dyhkw7";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Plugin for LLM adding support for Google's PaLM 2 model";
      homepage = "https://github.com/simonw/llm-palm";
    };
  };


  perplexity = buildPythonPackage rec {
    pname = "perplexity";
    version = "0.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1n6xb5hn1f06x1d21icz6i59dg8y5h0l2x01r3lxws4rl2m78jw4";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM access to pplx-api 3 by Perplexity Labs";
      homepage = "https://github.com/hex/llm-perplexity";
    };
  };


  python = buildPythonPackage rec {
    pname = "python";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1sfjp41zh41zayjpz8hppf8h5m2gp7vjwxscmb9yw8191gk8qrfn";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Run a Python interpreter in the LLM virtual environment";
      homepage = "https://github.com/simonw/llm-python";
    };
  };


  reka = buildPythonPackage rec {
    pname = "reka";
    version = "0.1a0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1lc5hwimlqg4n5xhgb785dcmb25k7rs6lqcgw3ll3l45j1ikn2zd";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Access Reka models via the Reka API";
      homepage = "https://github.com/simonw/llm-reka";
    };
  };


  replicate = buildPythonPackage rec {
    pname = "replicate";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1gvhhd6lm1gphkmnvy0v5nj118kqwn2ridfp6lvg0ma1bb7w8251";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "LLM plugin for models hosted on Replicate";
      homepage = "https://github.com/simonw/llm-replicate";
    };
  };


  sentence-transformers = buildPythonPackage rec {
    pname = "sentence-transformers";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1a5qypdlbk1425zy2l0fbnbw5x31kyrwpkwsqxb8kxcy0yqgax1x";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "Use sentence-transformers for embeddings with LLM";
      homepage = "https://github.com/simonw/llm-sentence-transformers";
    };
  };


  together = buildPythonPackage rec {
    pname = "together";
    version = "0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1vi7a9jj02vaz3b83zfl4l6adxdkxp3b7ym161z7mhjqcc3ajk08";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "llm together plugin";
      homepage = "https://github.com/wearedevx/llm-together";
    };
  };

}