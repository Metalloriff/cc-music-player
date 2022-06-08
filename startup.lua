term.clear()

print("Welcome to the media center!")

print("")

if peripheral.find("drive") == nil then
	print("ERR - In order to play songs, you need a disk drive connected. No valid disk drive was found.")
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
end

print("")

print("To save songs, they need to be converted to the DFPWMA audio format and uploaded to a static hosting site. For more information on this, enter 'help saving'.")
