{ inputs, outputs, pkgs, lib, options, ... }: 
{
   environment = {
    systemPackages = with pkgs; [
      hickory-dns   
      dogdns
    ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 853 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  environment.etc = {
    "hickory" = {
      source = ./config/hickory;
    };
  };

  users.users.hickory-dns = {
    isSystemUser = true;
    group = "hickory-dns";
    description = "Hickory DNS daemon user";
  };
  users.groups.hickory-dns = {};

  systemd.services.hickory-dns = {
    description = "Hickory DNS Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.hickory-dns}/bin/hickory-dns --config /etc/hickory/config.toml";
      User = "hickory-dns";
      Group = "hickory-dns";
      Restart = "on-failure";
    };
  };

}



