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
	
	For internal levels (the safer but less convienient route):
		1. In the project, create a new 3D scene
		2. Import the following folders:
			player_car/
			coolant/
		3. Import whatever assets your custom level needs and assemble it
		4. Drag in Player.tscn from player_car/scenes/
		5. Drag in the coolant.tscn scene from coolant/, place it wherever,
		and repeat until you have at least 20, or make the Player.tscn's
		"jugs_left" variable an export var and change it in the scene
		(This will be the default in a future release)
		6. Save the level's .tscn file in the res://maps/ folder to make it
		load on game start
		7. In the _on_levels_pressed() function in main_menu.gd, copy the 
		code for creating the bigcity_level button, and modify it for your
		own level, including creating a new pressed() signal method for the
		button.
	
	For external levels (allows loading levels after compile time):
		1. Create a new project in Godot 4.0.3 in an empty folder
		2. Have the following folders in your project:
			res://
				coolant/ (import this)
				level-assets/[map_name] (replace [map_name] with your map's name)
				mod_maps/ (where the file for the level will be stored)
				player_car/ (import this)
		3. Import whatever assets your level needs and assemble them in a new
		3D scene
		4. When your level is assembled, import Player.tscn and the 20 coolant
		jugs in the places you want
		5. When you're done, save the level as a .tscn in the mod_maps/ folder
		(IMPORTANT: do NOT save any other files in mod_maps/ as they will be
		loaded as a map and clog up the levels screen in the main menu)
		6. Go to the export menu, and click "Export as PCK/ZIP", and name the
		.pck file the same as your level's .tscn (So if you named your level
		level_terrainbridge.tscn, name the pack file level_terrainbridge.pck)
		7. Drop the .pck in the game's mod maps folder
			On Linux, it will be:
				~/.local/share/godot/app_userdata/MoodyCity/mod_maps
			On Windows, it is:
				%APPDATA%\Godot\app_userdata\MoodyCity\mod_maps
		8. Open the game and see your level in the main menu's level screen!

Build instructions:
	1. Clone or download this repository
	2. Open in Godot 4.0.3 
	3. Edit save path in the following places to use "user://" instead of "res://":
		res://stats_resource.gd (const SAVE_PATH)
		res://main_menu.gd (load() functions)
		res://Player.gd (@export var save_stats)
		
		These are set to res:// for debugging reasons
	
	4. Export game (I haven't made a proper build yet, so this has been untested)

Known issues:
	Because each coolant jug has its own OmniLight3D node, and there's 20 of them,
	there are some visual glitches in-game with lights that persist shortly after 
	deleting. An alternative solution for highlighting the coolant would fix
	this, but until I make one this bug will persist.
