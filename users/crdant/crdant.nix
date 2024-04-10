{ inputs, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;
in
{
  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users = {
    users.crdant = {
      isNormalUser = true;

      home = "/Users/crdant";
      shell = pkgs.zsh;
      description = "Chuck D'Antonio";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsWPxOAWaavdJo6Itgp2VXyCeQqAA4thIzuY8uxxTI1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAFXigWujG057J8k5SgLBu+AJkLjXMwGhV6EN14lNaFMAAAABHNzaDo="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoCrR7Alcy8u2Ef0rmU5CPR7H6A8VB1jMTlITHHmGdB"
        "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBHjhrp9FP2DfpzUEtZ8e/h1lFCBZbAO4pOdD/toikmzV7Mdh0zTlqHUEWrRA6zeQd9LLk2P352LOt75YHCZ87QoAAAAEc3NoOg=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX6f72jpsYAWdlQGLNlGeoz6AKsUl6FGDp48k/Z44QGqZdGymk3JUDO28BHBXJ05u6NiIad+x3hOYuKxglSjVjv8obqNnqAoJM8r2VLErlqwJNSSOzUijeA9V256Mq1ej7jTtYiNspI9TuyE9TOFsiS81tSIqgOGMJAe4Puqs89HZluLsh+XQSPHdiv//kJyhc5/isW7+z3t2jMfMJMBRLWaivZWSeDs8S3Fg6rIav4c7/r0jUKarMcNPhOLnR72uT9dykRrFEPWTuIDABuQft5oEck/MF2YymuRjLVsBeMuuOy4UyCnd8r06cPX4HoHMfpxRmzoJf68RSmBR+AmHN"
      ];

      group = if isDarwin then "staff" else "crdant";

      extraGroups = if isDarwin then
        [ "admin" ]
      else
        [ "adm" "ssher" "sudo"];
    };

    groups.crdant = {
      gid = 1002;
    };
}
