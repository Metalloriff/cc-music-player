local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local drive = peripheral.find("drive")

local songFile = fs.open("disk/song.txt", "r")

local uri = songFile.readAll()

songFile.close()

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
