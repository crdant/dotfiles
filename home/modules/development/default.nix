{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Development-related packages
  home = {
    packages = with pkgs; [
      exercism
      git-filter-repo
      git-lfs
      unstable.cue
      fermyon-spin
      nix-init
      nix-prefetch-git
      subversion
    ] ++ lib.optionals isDarwin [
    ];

    file = { };
  };

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
      ] ++ lib.optionals isDarwin [
        ngrok
      ];
    };
    
    git = {
      enable = true;
      
      userName = "Chuck D'Antonio";
      userEmail = "${gitEmail}";
      
      signing = {
        key = "0805EEDF0FEA6ACD";
        signByDefault = true;
      };
      
      aliases = { 
        ignore = "update-index --skip-worktree";
        unignore = "update-index --no-skip-worktree";
        ignored = "!git ls-files -v | grep \"^S\"";
        praise = "blame";
        unstash = "!f() { if [ $# -eq 0 ]; then echo \"Usage: git unstash <file1> [<file2> ...]\"; else for file in \"$@\"; do git checkout stash@{0} -- \"$file\"; done; fi }; f";
      };
      
      extraConfig = {
        core = {
          editor = "nvim";
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          
          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "${pkgs.openssh}/bin/ssh";
        };
        
        color = {
          ui = true;
          
          branch = { 
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };
          
          diff = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
            whitepace = "red reverse";
          };
          
          status = {
            added = "yellow";
            change = "green";
            untracked = "cyan";
          };
          
          merge = {
            conflictstyle = "zdiff3";
          };
          
          branch = {
            sort = "-commiterdate";
          };
        };
        
        init = {
          defaultBranch = "main";
        };
        
        diff = {
          plist = {
            textconv = "plutil -p";
          };
        };
        
        filter = {
          lfs = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
        };
      } // lib.optionalAttrs isDarwin {
        credential = {
          helper = "osxkeychain";
        };
      };
    };
    
    
    
  };
  
  programs = { 
    zsh = { 
      oh-my-zsh.plugins = [
        "git"
      ];
    };
  };
  
  
}
