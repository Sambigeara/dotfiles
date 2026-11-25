-- Publishes the directions the current window can't move in, so Rex decides locally (no RPC or
-- spawn) whether Ctrl-h/j/k/l belongs to Neovim or should focus the neighbouring Rex pane.
-- Outside normal mode nothing is an edge, so insert mode and pickers keep their keys.
local M = {}

function M.setup()
	if (vim.env.REX_SESSION or "") == "" then
		return
	end
	local dir = vim.fn.expand("~/.cache/rex-nav")
	vim.fn.mkdir(dir, "p")
	-- Under the TUI, config runs in an `--embed` child; Rex sees the TUI (our parent) as foreground.
	local embedded = vim.tbl_contains(vim.v.argv, "--embed")
	local path = dir .. "/" .. (embedded and vim.uv.os_getppid() or vim.fn.getpid())
	local last

	local function publish()
		local edges = ""
		if vim.api.nvim_get_mode().mode == "n" then
			local cur = vim.fn.winnr()
			for _, d in ipairs({ "h", "j", "k", "l" }) do
				if vim.fn.winnr(d) == cur then
					edges = edges .. d
				end
			end
		end
		if edges == last then
			return
		end
		local f = io.open(path, "w")
		if f then
			f:write(edges)
			f:close()
			last = edges
		end
	end

	for _, d in ipairs({ "h", "j", "k", "l" }) do
		vim.keymap.set("n", "<C-" .. d .. ">", "<C-w>" .. d)
	end

	local group = vim.api.nvim_create_augroup("rex_nav", { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "WinResized", "TabEnter", "ModeChanged" }, {
		group = group,
		callback = publish,
	})
	-- The closing window still exists while WinClosed runs.
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		callback = function()
			vim.schedule(publish)
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			os.remove(path)
		end,
	})
end

return M
