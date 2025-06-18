{ pkgs, ... }: {
  # Development tools and packages for software engineering workstations
  
  environment = {
    systemPackages = with pkgs; [
      git
      (python313.withPackages (ps: with ps; [
        pip
        setuptools
        wheel
        requests
        pyyaml
        click
        python-dateutil
      ]))
    ];
  };

  homebrew = {
    brews = [
      "chainguard-dev/tap/chainctl"
      "calicoctl"
    ];
  };
}
