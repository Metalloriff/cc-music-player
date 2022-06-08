local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local drive = peripheral.find("drive")

local arg = { ... }
local uri = nil

if arg[1] ~= nil then
	uri = args[1]
else
	local songFile = fs.open("disk/song.txt", "r")
	uri = songFile.readAll()

	songFile.close()
end

if uri == nil or not string.starts(uri, "https://") then
	print("ERR - Invalid URI!")
	return
end

while true do
	local response = http.get(uri, nil, true)

	local decoder = dfpwm.make_decoder()

	local chunkSize = 4 * 1024
	local chunk = response.read(chunkSize)
	while chunk ~= nil do
		local buffer = decoder(chunk)

		while not speaker.playAudio(buffer) do
			os.pullEvent("speaker_audio_empty")
		end

		chunk = response.read(chunkSize)
	end
end
