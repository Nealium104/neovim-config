return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
		},
		config = function()
			-- (f)ind (h)elp
			vim.keymap.set("n", "<space>fh", require('telescope.builtin').help_tags)
			-- (f)ind files in (d)irectory
			vim.keymap.set("n", "<space>fd", require('telescope.builtin').find_files)
			-- (e)dit (n)eovim
			vim.keymap.set("n", "<space>en", function()
				require('telescope.builtin').find_files {
					cwd = vim.fn.stdpath("config")
				}
			end)
		end
	}
}
