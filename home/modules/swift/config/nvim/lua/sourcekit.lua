local lspconfig = require'lspconfig'

-- Enable SourceKit-LSP
lspconfig.sourcekit.setup{
    cmd = { "xcrun", "sourcekit-lsp" }, -- Uses Apple's sourcekit-lsp
    filetypes = { "swift" } -- Only enable for Swift files
}
