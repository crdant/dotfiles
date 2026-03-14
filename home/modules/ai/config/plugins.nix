{
  marketplaces = {
    "claude-plugins-official" = "anthropics/claude-plugins-official";
    "compound-engineering-plugin" = "git@github.com:EveryInc/compound-engineering-plugin.git";
    "compound-knowledge-marketplace" = "git@github.com:EveryInc/compound-knowledge-plugin.git";
  };
  plugins = [
    "gopls-lsp@claude-plugins-official"
    "pyright-lsp@claude-plugins-official"
    "swift-lsp@claude-plugins-official"
    "typescript-lsp@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "claude-md-management@claude-plugins-official"
    "compound-engineering@compound-engineering-plugin"
    "compound-knowledge@compound-knowledge-marketplace"
    "hookify@claude-plugins-official"
  ];
}
