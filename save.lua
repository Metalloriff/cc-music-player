local arg = { ... }

if arg[2] ~= nil then
	local file = fs.open("disk/song.txt", "w")

	peripheral.find("drive").setDiskLabel(arg[1])

	file.write(arg[2])

	print("Sucessfully wrote song to floppy.")

	file.close()
else
	print("Invalid syntax!")
	print("Correct syntax: save <song name> <song url>")
end
