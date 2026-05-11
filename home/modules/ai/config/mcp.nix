# Shared MCP server definitions consumed by each agent module.
#
# secretRenderer: a function (sopsPath -> string) that produces the secret
# value in the calling agent's native format.
#   - Claude Code (default): sops placeholder for template substitution
#   - OpenCode:  "{env:FIRECRAWL_API_KEY}" style references
#   - Codex:     bare env var name for bearer_token_env_var / env_vars fields
#
# toEnvVarName: converts sops paths to env var names, e.g.
#   "firecrawl/api_key" → "FIRECRAWL_API_KEY"
#   "github/token"      → "GITHUB_TOKEN"
{ config, pkgs, lib ? pkgs.lib,
  secretRenderer ? (path: config.sops.placeholder.${path}),
  ... }:
let
  toEnvVarName = path:
    let
      upper = lib.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      upperWithUnderscore = map (c: "_${c}") upper;
      withUnderscores = builtins.replaceStrings upper upperWithUnderscore path;
    in
      lib.toUpper (builtins.replaceStrings ["/"] ["_"] (lib.removePrefix "_" withUnderscores));

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
      FIRECRAWL_API_KEY = secretRenderer "firecrawl/api_key";
    };
  };
  shortcut = {
    command = npxPath;
    args = [ "-y" "@shortcut/mcp@latest" ];
    env = {
      SHORTCUT_API_TOKEN = secretRenderer "shortcut/api_token";
    };
  };
  omni = {
    command = npxPath;
    args = [ "@omni-co/mcp" ];
    env = {
      DEBUG = "true";
      MCP_SERVER_URL = "https://replicated.omniapp.co/mcp/https";
      OMNI_API_TOKEN = secretRenderer "omni/api_token";
    };
  };
  github = {
    command = "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server";
    type = "http";
    url = "https://api.githubcopilot.com/mcp";
    headers = {
      "Authorization" = "Bearer ${secretRenderer "github/token"}";
    };
  };
  mbta = {
    command = "${pkgs.mbta-mcp-server}/bin/mbta-mcp-server";
    args = [ ];
    env = {
      MBTA_API_KEY = secretRenderer "mbta/apiKey";
    };
  };
  google-maps = {
    command = npxPath;
    args = [ "-y" "@modelcontextprotocol/server-google-maps" ];
    env = {
      GOOGLE_MAPS_API_KEY = secretRenderer "google/maps/apiKey";
    };
  };
  repomix = {
   command = npxPath;
    args = [ "-y" "repomix" "--mcp" ];
  };
}
