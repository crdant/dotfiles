 { lib, vimUtils, fetchFromGitHub }:
 let 
  version = "6.3.0";
  in
  vimUtils.buildVimPlugin {
    pname = "xcodebuild.nvim";
    version = version;
    src = fetchFromGitHub {
      owner = "wojciech-kulik";
      repo = "xcodebuild.nvim";
      rev = "v${version}";
      sha256 = "sha256-9VSj5vKKUIUEHsh8MrLjqCAOtf+0a10pDikzOSNTtbs=";
    };
    meta.homepage = "https://github.com/wojciech-kulik/xcodebuild.nvim";
}
