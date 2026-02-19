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
  puppeteer = {
    command = npxPath;
    args = ["-y" "@modelcontextprotocol/server-puppeteer" ];
  };
  time = {
    command = uvxPath;
    args = ["mcp-server-time" "--local-timezone=America/New_York"];
  };
  todoist = {
    type = "http";
    url = "https://ai.todoist.net/mcp";
  };
  firecrawl = {
    command = npxPath;
    args = [ "-y" "firecrawl-mcp" ];
    env = {
      FIRECRAWL_API_KEY = "${config.sops.placeholder."firecrawl/api_key"}";
    };
  };
  shortcut = {
    command = npxPath;
    args = [ "-y" "@shortcut/mcp@latest" ];
    env = {
      SHORTCUT_API_TOKEN = "${config.sops.placeholder."shortcut/api_token"}";
    };
  };
  omni = {
    command = npxPath;
    args = [ "@omni-co/mcp" ];
    env = {
      DEBUG = "true";
      MCP_SERVER_URL = "https://replicated.omniapp.co/mcp/https";
      MCP_API_KEY = "${config.sops.placeholder."omni/api_token"}";
    };
  };
  github = {
    command = "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server";
    type = "http";
    url = "https://api.githubcopilot.com/mcp";
    headers = {
      "Authorization" = "Bearer ${config.sops.placeholder."github/token"}";
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

