{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home = {
    packages = with pkgs; [
      govc
      knot-dns
      minio-client
      powershell
    ] ++ lib.optionals isDarwin [
      tart
    ];
    
    file = {
      ".config/ssh/config.d" = {
        source = ./config/ssh/config.d;
        recursive = true;
      };
      ".ssh/id_homelab.pub" ={
        text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDt39SrVyQAVPHEEkfjekQYO1GSrUU9UvBrznXgOcz60";
      };
      ".ssh/id_ipmi.pub" ={
        text = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgNg8ItxlZaCyyQ29V1Lp/0VHF6I7BWWBoU93djho2MGHK3neQEUnqV4/W9IbRVWOwKecORok3LZRunQ71MLNTynEnamHTtZ+OXbX3BBcaKR1vbPRsegVNmrHDANNBG6lh+J27C3LMvfE+pzdFxnPRzMCP2uA2sA/2nnFAC4p1u5CXU9ThqiaFPMi+Kjii+6CgQCaB1ExQQMJ/SCi/PQ16i8jZ+ibMxp5a/ms1hn/9W0QgGHAGSASspTINcP8mFwPjKFYnp2UJ2AKAMky9ifFt5U1sHEqZgRlwd2TdT3SpRxwPevHdNMxrh4DhJ7+dNuiPRDnyEqFBOcyuu1W8njZw4F/8q0pyTq2s7qPygDSDNJwbzz1gJEnJL3y31SiZDK+ZgHIFUCpTBqelyksZrXb4DX5tb1QN9vYbYG9Yc4J5Yp3qwPQ/6NQvbQV3V9b1In1rz6w+wgVxJ7OC7eDcA39vaKBnXJv37UbpaNtY6bOdHvzDApIsJg2YR34+IgJEble1AXPA4M1yuUswThNoztcZjbgfrEf/pRpgtkr74k2ylmuM4+C1AbWNfnGxxW6C1WZfBYZn0pD+uxbXqXRP+Qm8/WNueuo2K/TnHvhJkrdUXv2m4MdH87jwPjZwf9YPRhHxEYg0N5PoeixajJ9NGPhEblABaozVk0IqlbRcsFPAzw==";
      };
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      "Library/Application Support/espanso/match/snippets.yml" = {
        source = ./config/espanso/match/snippets.yml;
      };
    };
  };

  programs = {
    ssh = {
      settings = {
        "router" = {
          HostName = "router";
          User = "arceus";
          IdentityFile = "~/.ssh/id_router.pub";
          IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
          CanonicalizeHostname = "yes";
          CanonicalDomains = "walrus-shark.ts.net lab.shortrib.net";
          IdentitiesOnly = "yes";
        };

        "prism.lab.shortrib.net" = {
          User = "admin";
          IdentityFile = "~/.ssh/id_homelab.pub";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          IdentitiesOnly = "yes";
        };

        "bourbon.lab.shortrib.net rye.lab.shortrib.net scotch.lab.shortrib.net" = {
          User = "nutanix";
          IdentityFile = "~/.ssh/id_homelab.pub";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          IdentitiesOnly = "yes";
        };

        "ipmi.rye.lab.shortrib.net ipmi.bourbon.lab.shortrib.net ipmi.scotch.lab.shortrib.net" = {
          User = "arceus";
          IdentityFile = "~/.ssh/id_ipmi.pub";
          HostKeyAlgorithms = "+ssh-rsa";
          PasswordAuthentication = "yes";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          IdentitiesOnly = "yes";
        };

        "hypervisor.rye.lab.shortrib.net ahv.rye.lab.shortrib.net hypervisor.bourbon.lab.shortrib.net ahv.bourbon.lab.shortrib.net hypervisor.scotch.lab.shortrib.net ahv.scotch.lab.shortrib.net" = {
          User = "root";
          IdentityFile = "~/.ssh/id_homelab.pub";
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}
