local prefix = "ctrl+b>"

local function bind(key, action, args)
	rex.bind(prefix .. key, action, args)
end

bind("ctrl+b", "pane.send_key", { key = "ctrl+b" })
bind("r", "client.config.reload")
bind("s", "session.switch")
bind("ctrl+c", "session.switch")
bind("shift+;", "client.palette.toggle") -- :

bind("c", "session.new")
bind("n", "session.next")
bind("p", "session.previous")
bind(",", "session.rename")
bind("shift+7", "session.close") -- &
for i = 1, 9 do
	bind(tostring(i), "client.tab.goto", { index = i })
end

bind("shift+\\", "pane.split", { direction = "right" }) -- |
bind("shift+5", "pane.split", { direction = "right" }) -- %
bind("shift+-", "pane.split", { direction = "down" }) -- _
bind("shift+'", "pane.split", { direction = "down" }) -- "
bind("-", "pane.split", { direction = "down" })
bind("z", "pane.zoom")
bind("x", "pane.close")

bind("h", "pane.focus", { direction = "left" })
bind("j", "pane.focus", { direction = "down" })
bind("k", "pane.focus", { direction = "up" })
bind("l", "pane.focus", { direction = "right" })

-- Shift swaps with the neighbour. Plain h/j/k/l only moves focus.
bind("shift+h", "pane.move", { direction = "left" })
bind("shift+j", "pane.move", { direction = "down" })
bind("shift+k", "pane.move", { direction = "up" })
bind("shift+l", "pane.move", { direction = "right" })

-- Ctrl-h/j/k/l: Neovim (nvim/lua/rex_nav.lua) publishes its edge directions to
-- ~/.cache/rex-nav/<pid>. Not an edge: pass the key so Neovim moves its own window. An edge, or
-- not Neovim: focus the neighbouring pane here. A missing file means "pass", the safe default.
--
-- focus_direction picks the nearest pane, so with two panes flush against one edge it can't
-- tell which you came from. Reversing the last hop returns to the pane you left instead.
local opposite = { left = "right", right = "left", up = "down", down = "up" }
local hop

local function navigate(ctx, key, direction)
	local p = rex.block.call("com.superlogical.terminal", "process", {
		session_id = ctx.session_id,
		block_id = ctx.block_id,
	})
	local fg = p and p.foreground
	if fg and fg.name == "nvim" then
		local f = io.open(os.getenv("HOME") .. "/.cache/rex-nav/" .. fg.pid)
		local edges = f and f:read("*a") or ""
		if f then
			f:close()
		end
		if not edges:find(key, 1, true) then
			return false
		end
	end
	local sid = ctx.session_id
	local back = hop and hop.to == ctx.block_id and hop.direction == opposite[direction] and hop.from
	local to = back and rex.session.focus_block({ session_id = sid, block_id = back }) and back
	if not to then
		rex.session.focus_direction({ session_id = sid, direction = direction, wrap = true })
		local v = rex.session.view({ session_id = sid })
		for _, w in ipairs(v and v.windows or {}) do
			if w.window_id == v.active_window_id then
				to = w.focused_block_id
			end
		end
	end
	hop = { from = ctx.block_id, to = to, direction = direction }
	return true
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	local nav_key, nav_direction = key, direction
	rex.bind("ctrl+" .. nav_key, function(ctx)
		return navigate(ctx, nav_key, nav_direction)
	end)
end

rex.bind("ctrl+z", "pane.zoom")
rex.bind("ctrl+shift+h", "client.tab.move.backward")
rex.bind("ctrl+shift+l", "client.tab.move.forward")

bind("shift+=", "pane.resize", { direction = "up", amount = 10 }) -- +
bind("shift+,", "pane.resize", { direction = "left", amount = 10 }) -- <
bind("shift+.", "pane.resize", { direction = "right", amount = 10 }) -- >
