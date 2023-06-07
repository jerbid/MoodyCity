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
	
	Main menu skybox and textures taken from Polyhaven (License CC0):
		https://polyhaven.com
	Skybox (Kloppenheim 02) by Greg Zaal
	Grass texture (Forest Ground 01) by Rob Tuytel
	Bridge wood texture (Wood Planks Dirt) by Rob Tuytel
	
	RadioactivePoet for helping fix the in-game timer
	
	Code by me, Jerbid
	

--------------------------------------------------

How to add a new level in the project:
	1. Create a new 3D scene and import/create map model
	2. Add Player.tscn from res://player_car/scenes/ (This handles the car, UI, and gameplay all-in-one)
	3. Add 20 or more coolant.tscn from res://objects/ (coolant count will be dynamic in the future)
	4. [IMPORTANT] Save scene in the res://maps/ folder
	5. You're done! The main menu will detect the new level in the /maps folder and add it to the level screen.
	Note: The name in the levels screen will be determined based on the file name. ".tscn" will be removed, 
	but the rest will remain.
	
	Dynamic level loading is currently only supported when done inside the project in the editor. External level
	loading is planned for the future.

Build instructions:
	1. Clone or download this repository
	2. Open in Godot 4.0.3 
	3. Edit save path in the following places to use "user://" instead of "res://":
		res://stats_resource.gd (const SAVE_PATH)
		res://main_menu.gd (load() functions)
		res://Player.gd (@export var save_stats)
	4. Export game with default settings (or change some yourself, your choice)

Known issues:
	Headlight spotlights don't always work. This most likely is a problem with too many spotlights being present in the 
	game at once which should get fixed with occlusion culling which will be added in the near future (this will
	not be dynamic)
