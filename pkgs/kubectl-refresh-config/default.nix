{ pkgs }:

pkgs.writeShellApplication {
  name = "kubectl-refresh_config";
  runtimeInputs = with pkgs; [ findutils coreutils kubectl ];
  text = ''
    kubeconfig_path=$(find "$HOME/.kube" -maxdepth 1 -name '*.kubeconfig' | paste -sd ':')
    if [[ -z "$kubeconfig_path" ]]; then
      echo "No .kubeconfig files found in $HOME/.kube" >&2
      exit 1
    fi
    KUBECONFIG="$kubeconfig_path" kubectl config view --merge --flatten > "$HOME/.kube/config"
  '';
}
