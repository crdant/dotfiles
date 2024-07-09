{ lib, buildPythonPackage, fetchzip, llm }:
{

  anyscale-endpoints = buildPythonPackage rec {
    pname = "anyscale-endpoints";
    version = "0.1";
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/9f/01/d3613b61a533a1a4f5d510e182bde539735abf5b49fe39bf1708b823851d/llm-anyscale-endpoints-0.1.tar.gz";
      sha256 = "1qzyb509k3sq8k2463xwz5zscz9jnrcs12zv5929w19sbcgs7j9g";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/9d/56/dc162724bbaace0e06271ebe9377ad2e068ac3ec0632fdcb6c7dd01e1784/llm-bedrock-anthropic-0.1.tar.gz";
      sha256 = "0pyp34ljb6l1h3352clqxys36wgwkd74x7had5lwmiyl1f6325g9";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/bc/d7/aee63158ce766883698153dc16027d7871b310dd5ebbebc9ff7e6db7b055/llm-bedrock-meta-0.1.tar.gz";
      sha256 = "0wxn67aa8x22f4gfih84hc0n5dg3316kwmc66w6ibci0d0iw4dig";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/0b/8a/2a87805a63a991879bd0772789584c69c4a1b392e3123816eea3b978b7fc/llm-claude-0.1.0.tar.gz";
      sha256 = "19dppbg2v332cvq2k57n3mm3dpz5q4d5b3ra4dm62236nfdbfzlf";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/5e/d4/a43d61f019bf541d495d80d33f756544cc0b8f33b48956b2fbe85ed4e5af/llm-claude-3-0.1.tar.gz";
      sha256 = "1v9r3rqy14cs7a7rh3p1fp9dprbz6wayf00nxlmj4ydr0vpyichy";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/7b/ef/f16404d79cff379f3098ce95cbe205929a01dfa6b5946331fdfe7b0e4f53/llm-clip-0.1.tar.gz";
      sha256 = "08nfaddj5mif38rx4rccgm6scdgf4456if2dc3vypwmr5ywhcwsx";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/49/6a/6e4d14f4bf77dc3845af67bb351e4d651a85228481cc31683791ab2c3fee/llm-cluster-0.1.tar.gz";
      sha256 = "1csla9wh7vmf7y6swmb006n8l9cafzg9xzy6flv9p2ywmxr75ykl";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/98/09/eb288f3412aadcf9e697966870f083385e30b2c75b22072cf227799a0f64/llm-cmd-0.1a0.tar.gz";
      sha256 = "1n34i4kiz287n7cki4b4i7fsn835p7cgyxsg4wm4c1805jw672ni";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/40/4d/ae961befdafc4ff3d316389bacebbb434a486ba4b939bc9eab684e2ad2a1/llm-cohere-0.9.tar.gz";
      sha256 = "1c5sc1l4qwb6sm3h6v8g2rgdrvn51whm1902zd63vsni178gr9sl";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/67/c8/7f5b5a6403a0527065ba9248068446abb41813d7e1c48a2c0980e0342e12/llm-command-r-0.1.tar.gz";
      sha256 = "140pdcfwxdvdxjj0fackmdlq8klh4bc3l6g2qiipwbm3jzkszq6q";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/dc/55/570bbc49c64ce563005bd9d65b2197501edda8d6458ec6960b25f44aa8db/llm-embed-jina-0.1.tar.gz";
      sha256 = "1zf90xd1zjyclxbasryiv7ivi074rpd2c440mg9rzh96hysb7pdv";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/3d/34/1d5c0f5ed5c34a0ee04468d3e149c827280e97c08013fe48669b5e3ed100/llm-embed-onnx-0.1.tar.gz";
      sha256 = "1jmnjigv2c8mmwrcgbck12a9kb9h9c8wp1lvfjm22xrv2bslbxpk";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/b7/3f/68f5c9e6a7bf4f2df4ee9c43132bd899a5950b8fddc955213e922eddbf9a/llm_fireworks-0.1a0.tar.gz";
      sha256 = "10m5xpn2g1m5ib69k5dcm6xj2vyq581jv27qafjbwaqfdww4qpik";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/3f/8b/b65e1300492dddd0287a60077239ef3080749ac3945ee63dfd565a00e53d/llm-gemini-0.1a0.tar.gz";
      sha256 = "1s7n1ng8lr5algr33ywajwj6md2f1z986k6vl8y1dhg7cwg81iwf";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/84/b8/eb8ce8727a4004364e35b2a8d03d7336b0063cbefbd90a0849d23490980e/llm-gpt4all-0.1.tar.gz";
      sha256 = "1amgld4m827vd4qnhrsk40qp10lssjsl1f8x1kv79sjxfq64qh9j";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/2f/fe/5b7548555e7b1a55265e5429218206e7ad2f549190a990ba2d7e21253e1b/llm-groq-0.1.tar.gz";
      sha256 = "0ak09fz1p4v50xxqa8azv7ilx6w98l5azrh95bc3yyzz66jxjyf8";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/a6/9a/6b0cb790083f8840c547efd39e646057a5ceb2428b3fe391d8d4066d7880/llm-llama-cpp-0.1a0.tar.gz";
      sha256 = "1061nynv4vfw1my5hl9qww9nyy9s4aihn5q00ldxyfpvladwkk2d";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/cb/91/1b7e844fddccd7e1b03ffecb2bfd70bb2eca0383d19604df21015cded932/llm_llamafile-0.1.tar.gz";
      sha256 = "0dyhwjmcd5s7hk5q8b88va14qrzbdada2jpvv7agmapixzjzx8d5";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/54/c5/ad7db3d895e423cf4fdb546e3c58122dbf0b5e335359df04d2e0c34f84a5/llm-markov-0.1.tar.gz";
      sha256 = "0i8zlml40h3zh2vyxlg78gnda2fh7vl0i06wxxzbhv889yqy36dr";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/99/5e/2aa7b46363b554e32937b4b4e871fa86acab20d435392b895f87d0da5e91/llm-mistral-0.1.tar.gz";
      sha256 = "16p44iwbjvvx5scqna6nvln2m687h3aqmpabkvhb9k14imnnwg10";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/ef/0c/52fb493d035028a188475e7173331ac9f495c229eebd89f78b8cdf3cf70c/llm-mlc-0.1a0.tar.gz";
      sha256 = "04z9627irmmxyn9ckpdsdh35b77bdrncz0q49kbkq122fp73ka8l";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/3c/89/d53f4453f8d1e729c214d7fd293e705778e40df05734d0dac5aac7cd5ded/llm-mpt30b-0.1.tar.gz";
      sha256 = "0wj6hcfdxhmq69d14f67r906qnxjgch3p4w1ir5jsds0njkx8g0k";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/69/5f/f9e71f047905eb26827cbfb173e789f68ffc5541f2b96f7592b7a6f21c61/llm-ollama-0.1.0.tar.gz";
      sha256 = "0pwkmg6h04dqjiz843jg4fnbvslawsdalg66m2x0g1fc3fl0lxkc";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/d1/16/014add0f8f9d3aff28988786b82db6f6767e4108f8098517b11e316f6d2e/llm-openrouter-0.1.tar.gz";
      sha256 = "1i5n6x719i482kqaifjg6c1frfm9wd9ybh198xr6s16hv6qyz982";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/8b/f4/1cb9aad948f715a8af64c2dd5cc34d64b0c2f6b5c7864d0de22602b24864/llm-palm-0.1.tar.gz";
      sha256 = "1x94rw27kamj28qk34z7yrdccm2rfga4a0kxzgi3f2zizijlrg6h";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/da/a1/d0b9eb1995cdd77287540ae5385d02d48f51ee866a67149fbbe02ff98b8c/llm-perplexity-0.2.tar.gz";
      sha256 = "1935rlwmhinc1cyip8ypk7s829bkd8qbszd315pdd7dw321ny4mk";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/f2/1d/458635c7ba0fd7ad5b26c356cd489791afd00b68dfdbc09159c13d8e3b7d/llm-python-0.1.tar.gz";
      sha256 = "0yjyw7kbp1wc2jl0jl6llvgfxya3wh3mklf4mllizcw5abnwf73f";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/fb/e8/66d8be167a5c9aac0f9cf91aafcaddb00bec3746bb360e365d35eb5b3417/llm_reka-0.1a0.tar.gz";
      sha256 = "11h3p2a91ls466ymmv7c1swmdcs6kazcibjvpxlyy7p529cynnfi";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/f0/ae/3cac2bfb3fc6430046c710a5cd0612648e3a894b8bf71b44e7023628aa42/llm-replicate-0.1.tar.gz";
      sha256 = "0r8xrs6i983zg0qy98a4yb42p4prvb1rb42kazy97xfpa31vrm5v";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/e4/5b/76f4397d6a0ef309965fd6665967d3eb40d0b0f70e0ccd88a08a69267a87/llm-sentence-transformers-0.1.tar.gz";
      sha256 = "1g01h2szn2n1lks9g0lky1k4knkpcr5cwlmwv954p2ghgms16w6z";
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
    pyproject = true;

    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/13/9e/93573d7338d20ced333369cc73dcbb63cadbad83e6ebec3c4089ea64cc07/llm-together-0.1.tar.gz";
      sha256 = "1kw9kcnw6m3dirvvzc0na1agn3gr3s0k5gsgrwkgqzi7jkdlhnad";
    };

    doCheck = false;
    propagatedBuildInputs = [ llm ];

    meta = with lib; {
      description = "llm together plugin";
      homepage = "https://github.com/wearedevx/llm-together";
    };
  };

}