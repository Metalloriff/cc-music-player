local w, h = term.getSize()
local selectedEntry = 1

local menus = {}
local currentMenu = "main"
local running = true

function render()
	term.clear()
	term.setCursorPos(1, 1)

	local menu = menus[currentMenu] or menus["main"]

	if selectedEntry > #menu.entries then
		selectedEntry = 1
	end

	if currentMenu ~= "main" then
		table.insert(menu.entries, {
			label = "[BACK]",
			callback = function()
				currentMenu = menu.parent or "main"

				render()
			end
		})
	end

	for i = 1, #menu.entries do
		local caret = selectedEntry == i and ">> " or "   "
		term.setTextColor(selectedEntry == i and colors.magenta or colors.white)

		print(caret .. menu.entries[i].label)
	end
end

function onKeyPress(key)
	local menu = menus[currentMenu] or menus["main"]

	local switch = (({
		[keys.enter] = menu.entries[selectedEntry].callback or function() end,

		[keys.up] = function()
			selectedEntry = selectedEntry - 1
		end,

		[keys.down] = function()
			selectedEntry = selectedEntry + 1
		end
	})[key] or function() end)

	switch()

	if selectedEntry > #menu.entries or selectedEntry <= 0 then
		selectedEntry = 1
	end
end

function thread()
	while running do
		render()

		local event, key = os.pullEvent "key"
		onKeyPress(key)
	end
end

return {
	init = function(m) menus = m end,
	exit = function() running = false end,
	render = render,
	thread = thread
}
