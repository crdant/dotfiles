{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Kubernetes and container-related packages
  home.packages = with pkgs; [
    argocd
    conftest
    crane
    helmfile
    imgpkg
    istioctl
    krew
    kubectl
    kubernetes-helm
    k0sctl
    kots
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
  
  programs.zsh.oh-my-zsh.plugins = [
    "kubectl"
    "kubectx"
    "helm"
  ];
  
  home.sessionPath = [
    "$HOME/.krew/bin" 
  ];
}