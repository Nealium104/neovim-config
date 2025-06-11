return {
    {
	"neovim/nvim-lspconfig",
	dependencies = {
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
	config = function ()
	    local lspconfig = require("lspconfig")
	    lspconfig.lua_ls.setup{}
	    lspconfig.intelephense.setup{}
	    lspconfig.dockerls.setup{}

	    vim.api.nvim_create_autocmd('LspAttach', {
		callback = function(args)
		    local client = vim.lsp.get_client_by_id(args.data.client_id)
		    if not client then return end

		    ---@diagnostic disable-next-line: missing-parameter
		    if client.supports_method('textDocument/formatting') then
			-- format the current buffer on save
			vim.api.nvim_create_autocmd('BufWritePre', {
			    buffer = args.buf,
			    callback = function ()
				vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
			    end,
			})
		    end
		end,
	    })
	end,
    }
}
