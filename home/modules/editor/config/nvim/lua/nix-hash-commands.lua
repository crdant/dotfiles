-- nix-hash-commands.lua
-- Neovim commands for fetching Nix hashes and inserting them at cursor

local M = {}

-- Helper function to normalize GitHub URLs with various syntactic sugar
local function normalize_github_url(input)
    -- Already a full URL
    if input:match('^https?://') then
        return input
    end
    
    -- GitHub shorthand patterns
    if input:match('^[%w%-_%.]+/[%w%-_%.]+$') then
        -- owner/repo
        return 'https://github.com/' .. input .. '.git'
    elseif input:match('^gh:') then
        -- gh:owner/repo
        local repo = input:sub(4) -- remove 'gh:' prefix
        return 'https://github.com/' .. repo .. '.git'
    elseif input:match('^github:') then
        -- github:owner/repo
        local repo = input:sub(8) -- remove 'github:' prefix
        return 'https://github.com/' .. repo .. '.git'
    elseif input:match('^git@github%.com:') then
        -- git@github.com:owner/repo.git -> https://github.com/owner/repo.git
        local repo = input:match('^git@github%.com:(.+)$')
        if not repo:match('%.git$') then
            repo = repo .. '.git'
        end
        return 'https://github.com/' .. repo
    end
    
    return nil
end

-- Helper function to convert hash to SRI format
local function convert_to_sri(hash)
    local convert_result = vim.fn.system('nix hash convert --hash-algo sha256 --to sri ' .. vim.fn.shellescape(hash))
    local sri_hash = vim.trim(convert_result)
    
    if vim.v.shell_error ~= 0 then
        return nil, 'Error running nix hash convert: ' .. sri_hash
    end
    
    return sri_hash, nil
end

-- Setup function to create all commands
function M.setup()
    -- NixUrlHash command for fetching URL hashes
    vim.api.nvim_create_user_command('NixUrlHash', function(opts)
        local url = opts.args
        if url == '' then
            vim.notify('Error: URL required', vim.log.levels.ERROR)
            return
        end
        
        vim.notify('Fetching hash for: ' .. url, vim.log.levels.INFO)
        
        -- Run both commands in a pipeline
        local cmd = string.format(
            'nix-prefetch-url %s | xargs nix hash convert --hash-algo sha256 --to sri',
            vim.fn.shellescape(url)
        )
        
        local result = vim.fn.system(cmd)
        local hash = vim.trim(result)
        
        if vim.v.shell_error ~= 0 then
            vim.notify('Error: ' .. hash, vim.log.levels.ERROR)
            return
        end
        
        vim.api.nvim_put({hash}, 'c', true, true)
        vim.notify('Hash inserted: ' .. hash, vim.log.levels.INFO)
    end, {
        nargs = 1,
        desc = 'Fetch URL with nix-prefetch-url and insert SRI hash at cursor'
    })

    -- NixGitHash command for fetching Git repository hashes with GitHub sugar
    vim.api.nvim_create_user_command('NixGitHash', function(opts)
        local args = vim.split(opts.args, '%s+')
        local input = args[1]
        local rev = args[2] -- optional revision
        
        if not input or input == '' then
            vim.notify('Error: Git URL or GitHub repo required', vim.log.levels.ERROR)
            vim.notify('Usage examples:', vim.log.levels.INFO)
            vim.notify('  :NixGitHash nixos/nixpkgs', vim.log.levels.INFO)
            vim.notify('  :NixGitHash gh:rust-lang/rust v1.70.0', vim.log.levels.INFO)
            vim.notify('  :NixGitHash https://gitlab.com/user/repo.git', vim.log.levels.INFO)
            return
        end
        
        -- Convert GitHub shorthand to full URL
        local url = normalize_github_url(input)
        if not url then
            vim.notify('Error: Invalid format', vim.log.levels.ERROR)
            vim.notify('Supported formats:', vim.log.levels.INFO)
            vim.notify('  owner/repo', vim.log.levels.INFO)
            vim.notify('  gh:owner/repo', vim.log.levels.INFO)
            vim.notify('  github:owner/repo', vim.log.levels.INFO)
            vim.notify('  git@github.com:owner/repo.git', vim.log.levels.INFO)
            vim.notify('  https://github.com/owner/repo.git', vim.log.levels.INFO)
            return
        end
        
        local display_name = input .. (rev and (' at ' .. rev) or '')
        vim.notify('Fetching git hash for: ' .. display_name, vim.log.levels.INFO)
        
        -- Build command with optional revision
        local cmd = 'nix-prefetch-git ' .. vim.fn.shellescape(url)
        if rev then
            cmd = cmd .. ' --rev ' .. vim.fn.shellescape(rev)
        end
        
        local json_result = vim.fn.system(cmd)
        
        if vim.v.shell_error ~= 0 then
            vim.notify('Error running nix-prefetch-git: ' .. json_result, vim.log.levels.ERROR)
            return
        end
        
        local ok, parsed = pcall(vim.fn.json_decode, json_result)
        if not ok then
            vim.notify('Error parsing JSON output', vim.log.levels.ERROR)
            return
        end
        
        local sha256_hash = parsed.sha256
        if not sha256_hash then
            vim.notify('Error: sha256 field not found in JSON output', vim.log.levels.ERROR)
            return
        end
        
        -- Convert to SRI format
        local sri_hash, err = convert_to_sri(sha256_hash)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
            return
        end
        
        -- Insert the SRI hash at cursor position
        vim.api.nvim_put({sri_hash}, 'c', true, true)
        vim.notify('Git hash inserted: ' .. sri_hash, vim.log.levels.INFO)
    end, {
        nargs = '+',
        desc = 'Fetch git repo with nix-prefetch-git and insert SRI hash at cursor'
    })
end

return M
