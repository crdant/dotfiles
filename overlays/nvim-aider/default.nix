 { lib, vimUtils, fetchFromGitHub, }:
 vimUtils.buildVimPlugin {
    pname = "nvim-aider";
    version = "main";
    src = fetchFromGitHub {
      owner = "GeorgesAlkhouri";
      repo = "nvim-aider";
      rev = "3d1d733a7a3cf726dc41d1c4f15df01d208c09e5";
      sha256 = "sha256-6DCHpO37SWagYg1ZqcqRJMox9rZaoPNJYEFXck1sUcs=";
    };
    meta.homepage = "https://github.com/GeorgesAlkhouri/nvim-aider";
}
