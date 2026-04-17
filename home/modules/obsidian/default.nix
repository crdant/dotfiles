{ pkgs, lib, config, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  homeDirectory = config.home.homeDirectory;
  vaultsDir = "${homeDirectory}/workspace/vaults";
in {
  home.packages = with pkgs; [
    obsidian-headless
  ] ++ lib.optionals isLinux [
    unstable.obsidian
  ];

  home.activation = {
    createVaultsDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${vaultsDir}"
    '';

    setVaultsPermissions = lib.hm.dag.entryAfter ["createVaultsDirectory"] (
      if isLinux then ''
        chgrp obsidian "${vaultsDir}"
        chmod g+rwxs "${vaultsDir}"
        ${pkgs.acl}/bin/setfacl -m g:obsidian:rwX "${vaultsDir}"
        ${pkgs.acl}/bin/setfacl -d -m g:obsidian:rwX "${vaultsDir}"
        ${pkgs.acl}/bin/setfacl -m g:obsidian-readonly:rX "${vaultsDir}"
        ${pkgs.acl}/bin/setfacl -d -m g:obsidian-readonly:rX "${vaultsDir}"
      '' else if isDarwin then ''
        chgrp obsidian "${vaultsDir}"
        chmod g+rwx "${vaultsDir}"
        /bin/chmod +a "group:obsidian allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" "${vaultsDir}"
        /bin/chmod +a "group:obsidian-readonly allow list,search,readattr,readextattr,readsecurity,file_inherit,directory_inherit" "${vaultsDir}"
      '' else ""
    );

    syncObsidianVault = lib.hm.dag.entryAfter ["setVaultsPermissions"] ''
      if [ -f "${homeDirectory}/.config/obsidian-headless/config.json" ]; then
        echo "Syncing Obsidian vault..."
        ${pkgs.obsidian-headless}/bin/ob sync --vault-path "${vaultsDir}/Notes" || echo "Obsidian sync failed — have you run 'ob login' and 'ob sync-setup --vault Notes'?"
      else
        echo "Obsidian headless not configured — run 'ob login' and 'ob sync-setup --vault Notes' first"
      fi
    '';
  };
}
