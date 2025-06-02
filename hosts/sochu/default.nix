{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../darwin.nix 
  ];

  ids.gids.nixbld = 30000;

  homebrew = {
    brews = [
      "chainguard-dev/tap/chainctl"
      "calicoctl"
    ];

    casks = [
      "microsoft-teams"
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
      instruqt
      iterm2
      k0sctl
      k9s
      kapp
      kompose
      melange
      mtr
      subversion
      # tinygo
      teams
      trivy
    ];
  };
} 
