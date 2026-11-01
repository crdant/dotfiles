let
  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
    sha256 = "sha256-qSKUzRVZ7thADBUexDOJlC557hOu47vwSbRZzgAz1KE=";
  };
in
  builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" (builtins.readFile authorizedKeysFile))
