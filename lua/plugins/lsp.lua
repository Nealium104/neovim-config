return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            'saghen/blink.cmp',
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },

        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local venv_path = vim.fn.getcwd() .. "/.venv/bin"
            vim.env.PATH = venv_path .. ":" .. vim.env.PATH

            local servers = {
                lua = {
                    cmd = { "lua-language-server" },
                    filetypes = { "lua" },
                    root_markers = { ".luarc.json", ".git" },
                },
                php = {
                    cmd = { "intelephense", "--stdio" },
                    filetypes = { "php" },
                    root_markers = { "composer.json", "composer.lock", ".git" },
                },
                docker = {
                    cmd = { "docker-langserver", "--stdio" },
                    filetypes = { "dockerfile", "Dockerfile" },
                    root_markers = { ".git" },
                },
                go = {
                    cmd = { "gopls" },
                    filetypes = { "go", "gomod" },
                    root_markers = { "go.mod", ".git" },
                },
                bash = {
                    cmd = { "bash-language-server", "start" },
                    filetypes = { "sh" },
                    root_markers = { ".git" },
                },
                c = {
                    cmd = { "clangd", "--background-index" },
                    filetypes = { "c", "cpp", "objc", "objcpp" },
                    root_markers = { ".git" },
                },
                python = {
                    cmd = { "ty", "server" },
                    filetypes = { "python" },
                    root_markers = { "pyproject.toml", ".git" },
                },
                typescript = {
                    cmd = { "typescript-language-server", "--stdio" },
                    filetypes = { "typescript", "javascript" },
                    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
                },
                html = {
                    cmd = { "vscode-html-language-server", "--stdio" },
                    filetypes = { "html" },
                    root_markers = { ".git" },
                },
                css = {
                    cmd = { "vscode-css-language-server", "--stdio" },
                    filetypes = { "css" },
                    root_markers = { ".git" },
                },
                json = {
                    cmd = { "vscode-json-language-server", "--stdio" },
                    filetypes = { "json" },
                    root_markers = { ".git" },
                },
                ansible = {
                    cmd = { "ansible-language-server", "--stdio" },
                    filetypes = { "yaml.ansible" },
                    root_markers = { "ansible.cfg", "inventory", ".git" },
                    settings = {
                        python = {
                            interpreterPath = "python",
                            activationScript = "activate"
                        },
                        ansible = {
                            path = "ansible"
                        },
                        validation = {
                            lint = {
                                enabled = true,
                                path = "ansible-lint"
                            }
                        },
                    }
                },
            }

            vim.filetype.add({
                extension = {
                    yml = function(path, bufnr)
                        -- Check if file is in a standard ansible directory structure
                        if path:match("playbooks") or path:match("roles") or path:match("tasks") then
                            return "yaml.ansible"
                        end

                        -- Fallback: Check file content for Ansible keywords
                        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
                        if content:match("^%-%s?hosts:") or content:match("^%-%s?name:") then
                            return "yaml.ansible"
                        end

                        return "yaml"
                    end,
                },
                pattern = {
                    -- Force specific filenames
                    [".*/playbooks/.*%.yml"] = "yaml.ansible",
                    [".*/roles/.*%.yml"]     = "yaml.ansible",
                    ["ansible.yml"]          = "yaml.ansible",
                },
            })

            for name, cfg in pairs(servers) do
                cfg.capabilities = cfg.capabilities or capabilities
                vim.lsp.config(name, cfg)
                vim.lsp.enable(name)
            end

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    ---@diagnostic disable-next-line: missing-parameter
                    if client:supports_method('textDocument/formatting') then
                        -- format the current buffer on save
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                            end,
                        })
                    end
                end,
            })
        end,
    }
}
