LICENSE
-------
Rissu Project (C) 2024
kernel and ci: @RissuDesu

I. How to install the kernel:
- For img file:
	1. Boot to twrp,
	2. Go to Install menu
	3. Click Install Image
	4. Flash the img file
	5. Reboot

- For tar file:
	1. Boot to download mode.
	2. Open odin (for windows) or odin4 (for linux)
	3.1 For odin: put it at AP slot, and then proceed to flash it
	3.2 For odin4: Open terminal, and type:
		
		## Get device path
		odin4 -l
		-> output: /dev/bus/usb/001/018
		
		odin4 -a TragicHorizon.tar -d /dev/bus/usb/001/018
