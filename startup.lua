term.clear()

settings.define("media_center.volume", {
	description = "The volume to play songs at.",
	default = 1.0,
	type = "number"
})

print("Welcome to the media center!")

print("")

if peripheral.find("drive") == nil then
	print("WARN - No valid disk drive was found. You will have to save files to the device using `savetodevice`, or, connect a disk drive.")
else
	print("To play songs, just insert a disk into the connected disk drive, and run the 'play' command.")
end

print("")

if peripheral.find("speaker") == nil then
	print("ERR - No valid speaker was found!")
else
	local speaker = peripheral.find("speaker")
	local instr = "bell"

	speaker.playNote(instr, 3, 4)
	sleep(0.3)
	speaker.playNote(instr, 3, 8)
	sleep(0.3)
	speaker.playNote(instr, 3, 15)
	sleep(0.3)
	speaker.playNote(instr, 3, 16)
	sleep(0.5)

	speaker.playNote(instr, 3, 4)
	sleep(0.01)
	speaker.playNote(instr, 3, 8)
	sleep(0.01)
	speaker.playNote(instr, 3, 15)
	sleep(0.01)
	speaker.playNote(instr, 3, 16)
	sleep(0.01)

	local updateUri = "https://raw.githubusercontent.com/Metalloriff/cc-music-player/main/version.txt"

	local updateResponse = http.get(updateUri)

	if fs.exists("version.txt") then
		local updateFile = fs.open("version.txt", "r")

		if updateFile.readAll() ~= updateResponse.readAll() then
			print("")
			print("NOTE - There is an update available! To get the latest version, type 'download' into the console.")
		end
	end
end

print("")

print("To save songs, they need to be converted to the DFPWMA audio format and uploaded to a static hosting site. For more information on this, enter 'help saving'.")

if fs.exists("download.lua") then fs.delete("download.lua") end
if fs.exists("install.lua") then fs.delete("install.lua") end
