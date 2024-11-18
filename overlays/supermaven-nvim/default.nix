 { lib, vimUtils, fetchFromGitHub, }:
 vimUtils.buildVimPlugin {
    pname = "supermaven.vim";
    version = "2024-05-10";
    src = fetchFromGitHub {
      owner = "supermaven-inc";
      repo = "supermaven-nvim";
      rev = "07d20fce48a5629686aefb0a7cd4b25e33947d50";
      sha256 = "sha256-1z3WKIiikQqoweReUyK5O8MWSRN5y95qcxM6qzlKMME";
    };
    meta.homepage = "https://sueprmaven.com";
}
