{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
buildInputs = [
    pkgs.powershell
];

shellHook = ''
    echo "Starting PowerShell with VMware PowerCLI"
    pwsh -Command "Install-Module VMware.PowerCLI -Scope CurrentUser -AllowClobber -Force"
'';
}

