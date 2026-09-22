let
  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
    sha256 = "sha256-Yda8N3zy5GPPrJII8xOH9/Jfyh7/jo7LKy3FbVabi4U=";
  };
in
  builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" (builtins.readFile authorizedKeysFile))
