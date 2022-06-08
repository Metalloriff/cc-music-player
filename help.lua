local arg = { ... }

if arg[1] == "saving" then
	print("This is a 4-step tutorial on saving files to a floppy disk. Enter 'help saving 1' for part one, and so-on.")

	if arg[2] == "1" then
		term.clear()

		print("Step 1 - Insert the the floppy disk into the disk drive.")
	end

	if arg[2] == "2" then
		term.clear()

		print("Step 2 - Convert your audio file to the DFPWMA file format.")
		print("Step 2B - To do this, open your web browser and navigate to https://music.madefor.cc/ and simply drag your audio file onto the box.")
		print("Step 2C - Once it finishes, download it to your PC.")
	end

	if arg[2] == "3" then
		term.clear()

		print("Step 3 - Upload your DFPWMA to a static file hosting service. (EX: catbox.moe)")
		print("Step 3B - On your web browser, navigate to https://catbox.moe/ and drag your DFPWMA audio file onto the upload box.")
		print("Step 3C - Once the upload is complete, copy the file URL.")
	end

	if arg[2] == "4" then
		term.clear()

		print("Step 4 - Enter the save command as desired, surrounding the name of the disk and the URL with quotes.")
		print('Example - save "Tobu Candyland" "https://files.catbox.moe/swtak2.dfpwm"')

		print("")

		print("You're done! Now you can run 'play' to make sure that everything works properly, and you can safely eject your floppy and save more songs.")
	end
end
