-- nix-hash-commands.lua
-- Neovim commands for fetching Nix hashes and inserting them at cursor

local M = {}

-- Helper function to normalize GitHub URLs with various syntactic sugar
local function normalize_github_url(input)
    -- Already a full URL
    if input:match('^https?://') then
        -- Ensure GitHub URLs end with .git
        if input:match('github%.com') and not input:match('%.git$') then
            return input .. '.git'
        end
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
    -- Debug command to test URL normalization
    vim.api.nvim_create_user_command('NixGitHashDebug', function(opts)
        local input = opts.args
        local url = normalize_github_url(input)
        
        vim.notify('Input: ' .. input, vim.log.levels.INFO)
        vim.notify('Normalized URL: ' .. (url or 'nil'), vim.log.levels.INFO)
        
        if url then
            -- Test if the URL is accessible
            local test_cmd = 'git ls-remote ' .. vim.fn.shellescape(url) .. ' HEAD'
            vim.notify('Testing with: ' .. test_cmd, vim.log.levels.INFO)
            
            local result = vim.fn.system(test_cmd)
            if vim.v.shell_error == 0 then
                vim.notify('✓ Repository is accessible', vim.log.levels.INFO)
            else
                vim.notify('✗ Repository access failed: ' .. result, vim.log.levels.ERROR)
            end
        end
    end, {
        nargs = 1,
        desc = 'Debug URL normalization for NixGitHash'
    })

    -- NixUrlHash command for fetching URL hashes
    vim.api.nvim_create_user_command('NixUrlHash', function(opts)
        local url = opts.args
        if url == '' then
            vim.notify('Error: URL required', vim.log.levels.ERROR)
            return
        end
        
        -- First get the hash using nix-prefetch-url
        local prefetch_result = vim.fn.system('nix-prefetch-url ' .. vim.fn.shellescape(url))
        
        if vim.v.shell_error ~= 0 then
            vim.notify('Error running nix-prefetch-url: ' .. prefetch_result, vim.log.levels.ERROR)
            return
        end
        
        -- Extract the last line (the actual hash) and trim it
        local lines = vim.split(prefetch_result, '\n')
        local sha256_hash = vim.trim(lines[#lines])
        
        -- Convert to SRI format
        local sri_hash, err = convert_to_sri(sha256_hash)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
            return
        end
        
        vim.api.nvim_put({sri_hash}, 'c', true, true)
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
        
        -- Build command with optional revision
        local cmd = 'nix-prefetch-git ' .. vim.fn.shellescape(url)
        if rev then
            cmd = cmd .. ' --rev ' .. vim.fn.shellescape(rev)
        end
        
        local full_output = vim.fn.system(cmd)
        
        if vim.v.shell_error ~= 0 then
            vim.notify('Error running nix-prefetch-git (exit code ' .. vim.v.shell_error .. '):', vim.log.levels.ERROR)
            
            -- Check for common error patterns and provide helpful messages
            if full_output:match('could not read Username') then
                vim.notify('Authentication error: This appears to be a private repository.', vim.log.levels.ERROR)
                vim.notify('For private repos, you may need to:', vim.log.levels.INFO)
                vim.notify('  1. Use SSH URL format: git@github.com:owner/repo.git', vim.log.levels.INFO)
                vim.notify('  2. Or ensure GitHub credentials are configured', vim.log.levels.INFO)
            elseif full_output:match('fatal: repository .* not found') then
                vim.notify('Repository not found. Check the URL/path is correct.', vim.log.levels.ERROR)
            elseif full_output:match('fatal: could not read') then
                vim.notify('Network or authentication error.', vim.log.levels.ERROR)
            else
                vim.notify(full_output, vim.log.levels.ERROR)
            end
            
            -- Additional debugging info
            vim.notify('Command that failed: ' .. cmd, vim.log.levels.DEBUG)
            
            -- Check if nix-prefetch-git is available
            if vim.fn.executable('nix-prefetch-git') == 0 then
                vim.notify('nix-prefetch-git is not available in PATH', vim.log.levels.ERROR)
            end
            return
        end
        
        -- Extract JSON from the output (everything from first { to last })
        local json_start = full_output:find('{')
        local json_end = full_output:find('}[^}]*$')
        
        if not json_start or not json_end then
            vim.notify('Error: Could not find JSON in nix-prefetch-git output', vim.log.levels.ERROR)
            vim.notify('Full output: ' .. full_output, vim.log.levels.DEBUG)
            return
        end
        
        local json_result = full_output:sub(json_start, json_end)
        local ok, parsed = pcall(vim.fn.json_decode, json_result)
        if not ok then
            vim.notify('Error parsing JSON output: ' .. tostring(parsed), vim.log.levels.ERROR)
            vim.notify('Extracted JSON was: ' .. json_result, vim.log.levels.ERROR)
            return
        end
        
        local sha256_hash = parsed.sha256
        if not sha256_hash then
            vim.notify('Error: sha256 field not found in JSON output', vim.log.levels.ERROR)
            vim.notify('Available fields: ' .. vim.inspect(vim.tbl_keys(parsed)), vim.log.levels.ERROR)
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
    end, {
        nargs = '+',
        desc = 'Fetch git repo with nix-prefetch-git and insert SRI hash at cursor'
    })
end

return M
