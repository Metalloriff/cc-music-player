local dfpwm = require("cc.audio.dfpwm")
local speakers = { peripheral.find("speaker") }
local drive = peripheral.find("drive")
local decoder = dfpwm.make_decoder()

local menu = require "menu"

local uri = nil
local volume = settings.get("media_center.volume") or 1.0
local selectedSong = nil
local paused = false
local currentSongName = ""
local showUI = true
local w, h = term.getSize()

if drive == nil or not drive.isDiskPresent() then
	local savedSongs = fs.list("songs/")

	if #savedSongs == 0 then
		error("ERR - No disk was found in the drive, or no drive was found. No sound files were found saved to device.")
	else
		local entries = {
			[1] = {
				label = "[CANCEL]",
				callback = function()
					error()
				end
			}
		}

		for i, fp in ipairs(savedSongs) do
			table.insert(entries, {
				label = fp:match("^([^.]+)"),
				callback = function()
					selectedSong = fp

					menu.exit()
				end
			})
		end

		menu.init({
			main = {
				entries = entries
			}
		})

		menu.thread()

		if selectedSong ~= nil then
			local fp = "songs/" .. selectedSong

			if fs.exists(fp) then
				local file = fs.open(fp, "r")

				uri = file.readAll()

				file.close()
			else
				print("Song was not found on device!")

				return
			end
		else error() end
	end
else
	local songFile = fs.open("disk/song.txt", "r")
	uri = songFile.readAll()

	songFile.close()
end

if uri == nil or not uri:find("^https") then
	print("ERR - Invalid URI!")
	return
end

function playChunk(chunk)
	if paused then
		return true -- Skip playing when paused
	end
	
	local returnValue = nil
	local callbacks = {}

	for i, speaker in pairs(speakers) do
		if i > 1 then
			table.insert(callbacks, function()
				speaker.playAudio(chunk, volume)
			end)
		else
			table.insert(callbacks, function()
				returnValue = speaker.playAudio(chunk, volume)
			end)
		end
	end

	parallel.waitForAll(table.unpack(callbacks))

	return returnValue
end

function stopAllSpeakers()
	for _, speaker in pairs(speakers) do
		speaker.stop()
	end
end

function drawVolumeBar(vol)
	local barWidth = w - 20
	local filled = math.floor((vol / 3) * barWidth)
	local empty = barWidth - filled
	
	local bar = "[" .. string.rep("=", filled) .. string.rep("-", empty) .. "]"
	return bar .. " " .. math.floor((vol / 3) * 100) .. "%"
end

function drawUI()
	if not showUI then return end
	
	-- Save current cursor position
	local currentX, currentY = term.getCursorPos()
	
	-- Draw UI at bottom of screen
	term.setCursorPos(1, h - 3)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.clearLine()
	
	-- Song info line
	local songInfo = "♪ " .. (currentSongName or "Unknown Song")
	if string.len(songInfo) > w then
		songInfo = string.sub(songInfo, 1, w - 3) .. "..."
	end
	print(songInfo)
	
	-- Status line
	term.clearLine()
	local status = (paused and "⏸ PAUSED" or "▶ PLAYING") .. " | Press H for help"
	print(status)
	
	-- Volume control line
	term.clearLine()
	local volumeDisplay = "Volume: " .. drawVolumeBar(volume)
	print(volumeDisplay)
	
	-- Reset colors and restore cursor
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(currentX, currentY)
end

function hideUI()
	showUI = false
	-- Clear the bottom 3 lines
	for i = h - 2, h do
		term.setCursorPos(1, i)
		term.clearLine()
	end
end

function showUIHelp()
	hideUI()
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.yellow)
	print("=== Music Player Controls ===")
	term.setTextColor(colors.white)
	print("")
	print("Playback Controls:")
	print("  Space - Pause/Resume")
	print("  S     - Stop and exit")
	print("  H     - Show/hide this help")
	print("")
	print("Volume Controls:")
	print("  ↑/↓   - Volume up/down (arrow keys)")
	print("  +/=   - Increase volume")
	print("  -/_   - Decrease volume")
	print("  0-9   - Set volume (0=0%, 9=90%)")
	print("")
	print("Display:")
	print("  I     - Show player status")
	print("  U     - Toggle UI display")
	print("")
	print("Text Commands:")
	print("  You can also type commands like:")
	print("  'volume 50', 'pause', 'resume', 'stop'")
	print("")
	term.setTextColor(colors.yellow)
	print("Press any key to return to player...")
	term.setTextColor(colors.white)
	
	os.pullEvent("key")
	term.clear()
	showUI = true
end

function handleKeyPress(key)
	if key == keys.space then
		-- Toggle pause/resume
		if paused then
			paused = false
			print("Resumed")
		else
			paused = true
			stopAllSpeakers()
			print("Paused")
		end
		
	elseif key == keys.s then
		-- Stop
		stopAllSpeakers()
		quit = true
		print("Stopped")
		
	elseif key == keys.h then
		-- Show help
		showUIHelp()
		
	elseif key == keys.u then
		-- Toggle UI
		if showUI then
			hideUI()
		else
			showUI = true
		end
		
	elseif key == keys.i then
		-- Show status
		showStatus()
		
	elseif key == keys.up then
		-- Volume up with arrow key
		setVolume(math.min(3, volume + 0.3))
		
	elseif key == keys.down then
		-- Volume down with arrow key
		setVolume(math.max(0, volume - 0.3))
		
	elseif key == keys.equals or key == keys.plus then
		-- Volume up
		setVolume(math.min(3, volume + 0.3))
		
	elseif key == keys.minus or key == keys.underscore then
		-- Volume down
		setVolume(math.max(0, volume - 0.3))
		
	elseif key >= keys.zero and key <= keys.nine then
		-- Set volume by number key
		local volumePercent = (key - keys.zero) * 10
		if volumePercent == 0 and key == keys.zero then volumePercent = 0 end
		local actualVolume = (volumePercent / 100) * 3
		setVolume(actualVolume)
	end
end

function setVolume(newVolume)
	if newVolume < 0 then newVolume = 0 end
	if newVolume > 3 then newVolume = 3 end
	
	volume = newVolume
	settings.set("media_center.volume", volume)
	settings.save()
	
	-- Don't print volume message if UI is shown (it's already displayed)
	if not showUI then
		print("Volume set to " .. math.floor((volume / 3) * 100) .. "%")
	end
end

function showStatus()
	print("=== Speaker Status ===")
	print("Song: " .. (currentSongName or "Unknown"))
	print("Volume: " .. math.floor((volume / 3) * 100) .. "%")
	print("Status: " .. (paused and "Paused" or "Playing"))
	print("Speakers connected: " .. #speakers)
	
	for i, speaker in pairs(speakers) do
		local side = peripheral.getName(speaker)
		print("  Speaker " .. i .. ": " .. side)
	end
	print("===================")
end

-- Determine current song name
if drive ~= nil and drive.isDiskPresent() then
	currentSongName = drive.getDiskLabel() or "Disk Song"
elseif selectedSong then
	currentSongName = selectedSong:match("^([^.]+)") or selectedSong
end

term.clear()
print("Loading: " .. currentSongName)
print("Volume: " .. math.floor((volume / 3) * 100) .. "%")
print("Press H for controls, U to toggle UI")
print("")

local quit = false

function play()
	while true do
		local response = http.get(uri, nil, true)

		local chunkSize = 4 * 1024
		local chunk = response.read(chunkSize)
		while chunk ~= nil do
			local buffer = decoder(chunk)

			while not playChunk(buffer) do
				if not paused then
					os.pullEvent("speaker_audio_empty")
				else
					sleep(0.1) -- Wait while paused
				end
			end

			chunk = response.read(chunkSize)
		end
	end
end

function handleInput()
	while true do
		local event, key = os.pullEvent()
		
		if event == "key" then
			handleKeyPress(key)
		elseif event == "char" then
			-- Handle text input for commands (optional fallback)
		end
	end
end

function updateUI()
	while not quit do
		drawUI()
		sleep(0.5) -- Update UI every half second
	end
end

function readUserInput()
	local commands = {
		["stop"] = function()
			stopAllSpeakers()
			quit = true
			print("Music stopped.")
		end,
		
		["pause"] = function()
			if not paused then
				paused = true
				stopAllSpeakers()
				print("Music paused. Type 'resume' to continue.")
			else
				print("Music is already paused.")
			end
		end,
		
		["resume"] = function()
			if paused then
				paused = false
				print("Music resumed.")
			else
				print("Music is not paused.")
			end
		end,
		
		["volume"] = function(vol)
			if vol then
				local volumePercent = tonumber(vol)
				if volumePercent and volumePercent >= 0 and volumePercent <= 100 then
					local actualVolume = (volumePercent / 100) * 3
					setVolume(actualVolume)
				else
					print("Volume must be a number between 0 and 100.")
				end
			else
				print("Current volume: " .. math.floor((volume / 3) * 100) .. "%")
			end
		end,
		
		["status"] = function()
			showStatus()
		end,
		
		["help"] = function()
			showUIHelp()
		end,
		
		["ui"] = function()
			if showUI then
				hideUI()
				print("UI hidden")
			else
				showUI = true
				print("UI shown")
			end
		end
	}

	while true do
		local input = string.lower(read())
		local commandName = ""
		local cmdargs = {}

		local i = 1
		for word in input:gmatch("%S+") do
			if i > 1 then
				table.insert(cmdargs, word)
			else
				commandName = word
			end
			i = i + 1
		end

		local command = commands[commandName]

		if command ~= nil then
			command(table.unpack(cmdargs))
		else 
			print('"' .. commandName .. '" is not a valid command! Type "help" for available commands.')
		end
	end
end

function waitForQuit()
	while not quit do
		sleep(0.1)
	end
end

parallel.waitForAny(play, handleInput, updateUI, readUserInput, waitForQuit)
