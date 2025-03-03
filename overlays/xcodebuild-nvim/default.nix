 { lib, vimUtils, fetchFromGitHub, }:
 vimUtils.buildVimPlugin rec {
    pname = "xcodebuild-nvim";
    version = "6.0.0";
    src = fetchFromGitHub {
      owner = "wojciech-kulik";
      repo = "xcodebuild.nvim";
      rev = "v${version}";
      sha256 = "sha256-czirTMHVE1TyMPRyOAyhb5LqZFOCHhYNK19G0K0meOg=";
    };
    meta.homepage = "";
}
