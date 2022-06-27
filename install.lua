local baseUri = "https://raw.githubusercontent.com/Metalloriff/cc-music-player/main/"
local files = { "help", "play", "save", "savetodevice", "startup", "menu", "setvolume" }

term.clear()

for _, file in pairs(files) do
	print("Downloading program '" .. file .. "'...")

	local fileInstance = fs.open(file .. ".lua", "w")
	local response = http.get(baseUri .. file .. ".lua")

	fileInstance.write(response.readAll())
	fileInstance.close()
end

local updateUri = "https://raw.githubusercontent.com/Metalloriff/cc-music-player/main/version.txt"

local updateResponse = http.get(updateUri)
local updateFile = fs.open("version.txt", "w")

updateFile.write(updateResponse.readAll())

print("Installation complete! Please restart your computer.")
