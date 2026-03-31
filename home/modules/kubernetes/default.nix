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

  launchd = lib.mkIf isDarwin {
    enable = true;
    agents = {
      "io.crdant.env.kubernetes" = {
        enable = true;
        config = {
          Label = "io.crdant.env.kubernetes";
          ProgramArguments = [
            "${pkgs.bash}/bin/bash"
            "-c"
            ''
              # Add krew bin to PATH for GUI Kubernetes tools
              CURRENT_PATH=$(launchctl getenv PATH)
              if [[ -z "$CURRENT_PATH" ]]; then
                # If PATH doesn't exist yet, set a basic one
                launchctl setenv PATH "${config.home.homeDirectory}/.krew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
              else
                # Prepend krew to existing PATH if not already present
                if [[ ":$CURRENT_PATH:" != *":${config.home.homeDirectory}/.krew/bin:"* ]]; then
                  launchctl setenv PATH "${config.home.homeDirectory}/.krew/bin:$CURRENT_PATH"
                fi
              fi
            ''
          ];
          RunAtLoad = true;
          StandardOutPath = "${config.xdg.stateHome}/launchd/env.kubernetes.out";
          StandardErrorPath = "${config.xdg.stateHome}/launchd/env.kubernetes.err";
        };
      };
    };
  };
}
