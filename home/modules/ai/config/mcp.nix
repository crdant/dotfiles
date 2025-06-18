{ config, pkgs, ... }:
let
  # Define paths to be templated
  nerdctlPath = "${config.home.homeDirectory}/.rd/bin/nerdctl";
  uvxPath = "${pkgs.uv}/bin/uvx";
  npxPath = "${pkgs.nodejs_22}/bin/npx";
in
{
  fetch = {
    command = uvxPath;
    args = ["mcp-server-fetch"];
  };
  memory = {
    command = npxPath;
    args = ["-y" "@modelcontextprotocol/server-memory"];
    env = {
      MEMORY_FILE_PATH = "${config.xdg.stateHome}/modelcontextprotocol/memory";
    };
  };
  puppeteer = {
    command = npxPath;
    args = ["-y" "@modelcontextprotocol/server-puppeteer" ];
  };
  time = {
    command = uvxPath;
    args = ["mcp-server-time" "--local-timezone=America/New_York"];
  };
  git = {
    command = uvxPath;
    args = [ "mcp-server-git" ];
  };
  github = {
    command = "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server";
    args = ["stdio" ];
    env = {
      GITHUB_PERSONAL_ACCESS_TOKEN = "${config.sops.placeholder."github/token"}";
    };
  };
  mbta = {
    command = "${pkgs.mbta-mcp-server}/bin/mbta-mcp-server";
    args = [ ];
    env = {
      MBTA_API_KEY = "${config.sops.placeholder."mbta/apiKey"}";
    };
  };
  google-maps = {
    command = npxPath;
    args = [ "-y" "@modelcontextprotocol/server-google-maps" ];
    env = {
      GOOGLE_MAPS_API_KEY = "${config.sops.placeholder."google/maps/apiKey"}";
    };
  };
  repomix = {
   command = npxPath;
    args = [ "-y" "repomix" "--mcp" ];
  };
}

