{ pkgs, ... }: {
  # Network debugging and connectivity tools
  
  environment = {
    systemPackages = with pkgs; [
      hostess
      inetutils
      mtr
      sipcalc
      tcptraceroute
    ];
  };
}