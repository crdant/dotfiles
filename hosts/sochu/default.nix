{ pkgs, ... }:
{
  imports = [
    ../darwin.nix 
  ];

  homebrew = {
    brews = [
      "chainguard-dev/tap/chainctl"
      "calicoctl"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      apko
      aws-sam-cli
      eksctl
      fermyon-spin
      fluxcd
      git-filter-repo
      golangci-lint
      goreleaser
      k0sctl
      k9s
      kapp
      kompose
      melange
      mtr
      subversion
      tinygo
    ];
  };
} 
