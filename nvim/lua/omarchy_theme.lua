local M = {}

local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
local path = state .. "/omarchy/current/theme/neovim.lua"
local current
local timer
local applied_source
local warned_source

local function read_theme()
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local source = file:read("*a")
	file:close()
	local chunk = loadstring(source, "@" .. path)
	if not chunk then
		return nil
	end
	local ok, definitions = pcall(chunk)
	if not ok or type(definitions) ~= "table" then
		return nil
	end
	local theme = { source = source, plugins = {} }
	for _, spec in ipairs(definitions) do
		if spec[1] == "LazyVim/LazyVim" then
			theme.colorscheme = spec.opts and spec.opts.colorscheme
		else
			-- Import only the theme plugins, without adopting LazyVim's editor setup.
			spec.lazy = true
			spec.opts = spec.opts or {}
			table.insert(theme.plugins, spec)
		end
	end
	if type(theme.colorscheme) == "string" and #theme.plugins > 0 then
		return theme
	end
end

function M.available()
	current = read_theme()
	return current ~= nil
end

function M.spec()
	return {
		name = "omarchy-colors",
		import = function()
			return vim.deepcopy(current.plugins)
		end,
	}
end

local function apply(reload)
	local config = require("lazy.core.config")
	local loader = require("lazy.core.loader")
	vim.o.background = "dark"
	for _, spec in ipairs(current.plugins) do
		local name = spec.name or spec[1]:match("([^/]+)$")
		local plugin = config.plugins[name]
		if plugin then
			if reload and plugin._.loaded then
				-- Palette-generated themes reuse one plugin with different options.
				plugin._.cache = nil
				loader.reload(plugin)
			else
				loader.load({ name }, { colorscheme = current.colorscheme })
			end
		end
	end
	vim.cmd.colorscheme(current.colorscheme)
	vim.api.nvim_set_hl(0, "EndOfBuffer", { link = "NonText" })
	if package.loaded.lualine then
		-- Re-resolve the automatic statusline palette after a theme change.
		require("lualine").setup({ options = { theme = "auto" } })
	end
end

function M.refresh()
	local next_theme = read_theme()
	-- Omarchy replaces its theme directory during a switch; retry on the next tick.
	if not next_theme or next_theme.source == applied_source then
		return
	end
	current = next_theme
	-- Reparse our dynamic import so newly selected plugins and options are available.
	-- These are the same Lazy internals used by Omarchy's stock hot-reload plugin.
	local ok, err = pcall(function()
		require("lazy.core.plugin").load()
		apply(true)
	end)
	if ok then
		applied_source = current.source
		warned_source = nil
	elseif warned_source ~= current.source then
		warned_source = current.source
		vim.notify("Omarchy theme: " .. tostring(err) .. "\nRun :Lazy sync if the theme plugin is missing.", vim.log.levels.WARN)
	end
end

function M.start()
	local ok, err = pcall(apply, false)
	if ok then
		applied_source = current.source
	else
		vim.notify("Omarchy theme: " .. tostring(err), vim.log.levels.WARN)
	end
	local group = vim.api.nvim_create_augroup("OmarchyTheme", { clear = true })
	vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = M.refresh })
	-- Poll the file contents: watching its inode misses Omarchy's directory swaps.
	timer = assert(vim.uv.new_timer())
	timer:start(2000, 2000, vim.schedule_wrap(M.refresh))
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			timer:stop()
			timer:close()
		end,
	})
end

return M
