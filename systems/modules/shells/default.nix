{ pkgs, lib, ... }: {
  # Shell configuration for human interaction
  
  # zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    '';

  # fishrc sourcing needed environment changes
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
    '';	
  # bash is enabled by default

  environment = {
    systemPackages = with pkgs; [
      zsh-completions
    ];

    shells = with pkgs; [ 
      bashInteractive
      fish
      zsh
    ];
  };
}