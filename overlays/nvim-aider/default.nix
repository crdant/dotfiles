 { lib, vimUtils, fetchFromGitHub, }:
 vimUtils.buildVimPlugin {
    pname = "nvim-aider";
    version = "main";
    src = fetchFromGitHub {
      owner = "GeorgesAlkhouri";
      repo = "nvim-aider";
      rev = "3554ffdd7f0f91167f83ab3e3475ba08a090061f";
      sha256 = "sha256-1ApWcUHUCPOo5H7NAiC/M2fN41j9fgPN6Gt3o4hfYbo=";
    };
    meta.homepage = "https://github.com/GeorgesAlkhouri/nvim-aider";
}
