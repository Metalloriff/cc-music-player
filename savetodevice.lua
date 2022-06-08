local arg = { ... }

if arg[2] ~= nil then
	local file = fs.open("songs/" .. arg[1] .. ".txt", "w")

	file.write(arg[2])

	print("Sucessfully wrote song to device. Play with 'play \"" .. arg[1] .. "\"'.")

	file.close()
else
	print("Invalid syntax!")
	print("Correct syntax: savetodevice <song name> <song url>")
end
