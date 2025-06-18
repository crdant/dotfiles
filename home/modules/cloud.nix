{ inputs, outputs, config, pkgs, lib, ... }:

{
  # Cloud provider tools
  home.packages = with pkgs; [
    azure-cli
    cloudflared
    google-cloud-sdk
    govc
    leftovers
    minio-client
    packer
    terraform
    terraform-lsp
    vault
  ];
  
  programs = {
    awscli = {
      enable = true;
      settings = {
        "default" = {
          region = "us-west-2";
          output = "json";
        };
        "personal" = {
          region = "us-west-2";
          output = "json";
        };
        "replicated-dev" = {
          region = "us-west-2";
          output = "json";
        };
      };
    };
    zsh = {
      oh-my-zsh = {
        plugins = [
          "gcloud"
          "aws"
          "vault"
          "terraform"
        ];
      };
    
      envExtra = ''
        export REPL_USE_SUDO=y
        export GOVC_URL=https://vcenter.lab.shortrib.net
        export GOVC_USERNAME=administrator@shortrib.local
        # export GOVC_PASSWORD=$(security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w)
        export GOVC_INSECURE=true
      '';
    };
  };
}
