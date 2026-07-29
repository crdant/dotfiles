let
  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
    sha256 = "sha256-hUjgwUIe/R8RxRgk7kT+wOFr6erF+fI6mQS1+3uRhe0=";
  };
in
  builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" (builtins.readFile authorizedKeysFile))
