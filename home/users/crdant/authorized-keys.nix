let
  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
    sha256 = "sha256-5e3hvuaYzdv3D36YiPEOVXb7S78Yfn4nmrQwlGFFCHU=";
  };
in
  builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" (builtins.readFile authorizedKeysFile))
