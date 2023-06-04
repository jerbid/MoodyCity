--------------------------------------------------
Moody City, the race-against-the-timer game 
about cooling down your engine made in Godot.
--------------------------------------------------
Made by Jerbid

CREDITS:
	Grand National font by Iconian Fonts
	https://www.iconian.com/
	Licensed for noncommercial purposes
	
	gm_bigcity map by BigWig on Steam
	
	Cone, lightpole and coolant models made by Ender Xero
	https://www.youtube.com/@enderxero1509
	
	Main menu skybox and textures taken from Polyhaven:
		https://polyhaven.com
	Skybox (Kloppenheim 02) by Greg Zaal
	Grass texture (Forest Ground 01) by Rob Tuytel
	Bridge wood texture (Wood Planks Dirt) by Rob Tuytel
	
	Code by me, Jerbid
	

--------------------------------------------------

How to add a new level:
	1. Create a new 3D scene and import/create map model
	2. Add Player.tscn from res://player_car/scenes/
	3. Add 20 or more coolant.tscn from res://objects/ (will be dynamically adjusted in the future)
	4. Save scene in res://maps/ folder
	5. You're done! Everything else is handled by the existing code.

Build instructions:
	1. Clone or download this repository
	2. Open in Godot 4.x (This is developed in 4.0.3 on Linux Mint 21)
	3. Edit SAVE_PATH in res://stats_resource to use "user://" instead of "res://"
	4. Export project, this currently has no defined export properties
