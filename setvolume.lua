local args = { ... }

if args[1] == nil or tonumber(args[1]) == nil then
	print("ERR - Please enter a number value between 0 and 100.")
else
	local volume = args[1]
	local actualVolume = (args[1] / 100) * 3

	settings.set("media_center.volume", actualVolume)

	print("Set the volume to " .. volume .. "%")
end
