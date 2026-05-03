-- Enable SourceKit-LSP
vim.lsp.config('sourcekit', {
    cmd = { "xcrun", "sourcekit-lsp" }, -- Uses Apple's sourcekit-lsp
    filetypes = { "swift" } -- Only enable for Swift files
})
vim.lsp.enable('sourcekit')
