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
      # open-policy-agent
      stern
      vendir
      ytt
    ] ++ lib.optionals isLinux [
      calicoctl
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
