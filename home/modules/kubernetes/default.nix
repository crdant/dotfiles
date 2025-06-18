{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Kubernetes and container-related packages
  home = {
    packages = with pkgs; [
      argocd
      conftest
      crane
      fluxcd
      helmfile
      imgpkg
      istioctl
      krew
      kubectl
      kubernetes-helm
      k0sctl
      k9s
      kapp
      kompose
      kubeseal
      kustomize
      kyverno-chainsaw
      open-policy-agent
      oras
      replicated
      skopeo
      stern
      tektoncd-cli
      troubleshoot-sbctl
      tunnelmanager
      vendir
      ytt
    ] ++ lib.optionals isLinux [
      calicoctl
      nerdctl
    ];
    sessionPath = [
      "$HOME/.krew/bin"
    ];
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

