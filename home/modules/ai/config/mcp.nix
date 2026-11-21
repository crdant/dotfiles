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
  time = {
    command = uvxPath;
    args = ["mcp-server-time" "--local-timezone=America/New_York"];
  };
  todoist = {
    type = "http";
    url = "https://ai.todoist.net/mcp";
  };
  mbta = {
    command = "${pkgs.mbta-mcp-server}/bin/mbta-mcp-server";
    args = [ ];
    env = {
      MBTA_API_KEY = secretRenderer "mbta/apiKey";
    };
  };
}
