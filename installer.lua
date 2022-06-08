local baseUri = "https://raw.githubusercontent.com/Metalloriff/cc-music-player/main/"
local files = { "help", "play", "save", "startup" }

for _, file in pairs(files) do
	print("Downloading program '" .. file .. "'...")

	local fileInstance = fs.open(file .. ".lua", "w")
	local response = http.get(baseUri .. file .. ".lua")

	fileInstance.write(response.readAll())
	fileInstance.close()
end

print("Installation complete! Please restart your computer.")
