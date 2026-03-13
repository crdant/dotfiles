{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Kubernetes-specific tools
  home = {
    packages = with pkgs; [
      conftest
      helm-beta
      helmfile
      istioctl
      krew
      kubectl
      k0sctl
      k9s
      kapp
      kompose
      kubeseal
      kustomize
      kyverno-chainsaw
      # unstable.open-policy-agent
      pack
      stern
      vendir
      ytt
    ] ++ lib.optionals isLinux [
      calicoctl
    ];
    sessionPath = [
      "$HOME/.krew/bin"
    ];

    activation = {
      krewPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        KREW="${pkgs.krew}/bin/krew"
        PLUGINS=(
          ctx
          get-all
          netshoot/netshoot
          ns
          outdated
          preflight
          schemahero
          support-bundle
        )
        $DRY_RUN_CMD $KREW update
        if ! $KREW index list 2>/dev/null | grep -q "^netshoot"; then
          $DRY_RUN_CMD $KREW index add netshoot https://github.com/nilic/kubectl-netshoot.git
        fi
        for plugin in "''${PLUGINS[@]}"; do
          if ! $KREW list 2>/dev/null | grep -q "^$plugin$"; then
            $DRY_RUN_CMD $KREW install "$plugin"
          fi
        done
      '';
    };
  };

  programs = {
    zsh = {
      oh-my-zsh = {
        plugins = [
          "kubectl"
          "kubectx"
          "helm"
        ];
      };
    };
  };
}
