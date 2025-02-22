 { lib, vimUtils, fetchFromGitHub, }:
 vimUtils.buildVimPlugin {
    pname = "nvim-aider";
    version = "main";
    src = fetchFromGitHub {
      owner = "GeorgesAlkhouri";
      repo = "nvim-aider";
      rev = "main";
      sha256 = "sha256-OTSLFrROzHXemFAk7VAAJwpolZ0Ws2WJ0j5qgs5aW0A=";
    };
    meta.homepage = "https://github.com/GeorgesAlkhouri/nvim-aider";
}
