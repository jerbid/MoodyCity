extends Node3D

@onready var title := $CanvasLayer/MainMenu/Title
@onready var main_buttons = $CanvasLayer/MainMenu/VBoxContainer
@onready var stats = $CanvasLayer/MainMenu/Stats
@onready var levels = $CanvasLayer/MainMenu/Levels
@onready var levels_container = $CanvasLayer/MainMenu/Levels/MarginContainer/VBoxContainer/LevelsContainer

@onready var lowest_time = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/LowestTime
@onready var coolant_collected = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/CoolantCollected
@onready var living_temp = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/LivingTemp
@onready var losses = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/Losses
@onready var wins = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/Wins
@onready var time_created = $CanvasLayer/MainMenu/Stats/MarginContainer/VBoxContainer/TimeCreated

var map_dir := OS.get_executable_path().get_base_dir().path_join("maps/")
var map_files : Array 
var save_stats : MoodyCitySaveStats
var maps : Array
var map_index : int
var maps_size : int

var ext_map_path : String = "user://mod_maps/"
var ext_map_array : Array
var ext_map_index : int

# --------------------------
# Main Menu Script
#---------------------------
# This script handles all of the logic for the main menu.
# Dynamic level loading from res://maps/ is handled here in the get_maps() and
# the add_level_buttons() functions.
# Statistics are also displayed here, loaded on the _on_stats_pressed() signal
#---------------------------

func _ready():
	ProjectSettings.load_resource_pack(map_dir + "bigcity_level.pck")
	print(str(map_files))
	for file in map_files:
		ProjectSettings.load_resource_pack(file)
	print(str(map_files))
	print(map_dir)
	# If there's no save data found, create a new one in the same path.
	# Otherwise, it just loads the existing one.
	if FileAccess.file_exists("user://moody_city_save.tres") == false:
		save_stats = MoodyCitySaveStats.new()
		save_stats.resource_path = save_stats.SAVE_PATH
		save_stats.save()
		print("no save data found, creating new")
		if FileAccess.file_exists("user://moody_city_save.tres") == false:
			print("something went wrong creating the save, no data will be saved")
		# Saves the current date and time to the save file
		save_stats.time_created = Time.get_datetime_string_from_system()
	else:
		save_stats = load("user://moody_city_save.tres")
	
	if not DirAccess.dir_exists_absolute("user://mod_maps/"):
		DirAccess.make_dir_absolute("user://mod_maps")
	elif not DirAccess.dir_exists_absolute(map_dir):
		DirAccess.make_dir_absolute(map_dir)
	else:
		pass

func _on_stats_pressed():
	title.visible = false
	main_buttons.visible = false
	stats.visible = true
	
	if save_stats.lowest_time == 99999999:
		lowest_time.text = "Fastest win: You haven't won yet!"
	else:
		lowest_time.text = "Fastest win: " + save_stats.get_lowest_time_as_string()
	
	# Changes the text in the stats menu to the values found in the save stats file.
	coolant_collected.text = "Total coolant jugs collected: " + str(save_stats.total_coolant_collected)
	living_temp.text = "Highest living temp: " + str(save_stats.highest_living_temp)
	losses.text = "Losses: " + str(save_stats.losses)
	wins.text = "Wins: " + str(save_stats.wins)
	time_created.text = "Save created on: " + save_stats.time_created
	
	
func _on_back_pressed():
	stats.visible = false
	levels.visible = false
	main_buttons.visible = true
	title.visible = true


func _on_play_game_pressed():
	get_tree().change_scene_to_file("res://maps/bigcity_level.tscn")


func _on_quit_game_pressed():
	save_stats.save()
	get_tree().quit()


func _on_levels_pressed():
	remove_old_buttons()
	var bigcity_button = Button.new()
	levels_container.add_child(bigcity_button)
	bigcity_button.text = "bigcity_level"
	bigcity_button.pressed.connect(_on_button_pressed)
	# Loads the internal levels and prints what it finds to the console.
	maps = get_maps()
	print("internal levels found: " + str(maps_size) + "\nfiles: " + str(maps))
#	# Adds buttons to the levels menu with the maps loaded above.
#	add_level_buttons()
	
	# Loads mod maps and adds buttons for each one
	var ext_maps : Array = get_ext_maps()
	add_ext_buttons()
	
	main_buttons.visible = false
	levels.visible = true


func _on_level_button_pressed(button):
	# Changes the scene to the file with the below path plus the button's text, 
	# minus the number and plus the .tscn file extension. 
	
	# For example, bigcity_level.tscn is converted to 1. bigcity_level on the
	# button in the levels menu, and it becomes bigcity_level.tscn again.
	get_tree().change_scene_to_file("res://maps/" + button.text + ".tscn")

func _on_ext_level_pressed(button):
	get_tree().change_scene_to_file("res://mod_maps/" + button.text + ".tscn")

# -------------------------- General functions ---------------------------------------

func get_maps() -> Array:
	map_files = DirAccess.get_files_at("maps/")
	var map_array : Array
	for pack in map_dir:
		ProjectSettings.load_resource_pack(pack)
	
	for file in map_files:
		if file.get_extension() == "tscn":
			map_array.append(file)
	
	maps_size = map_array.size()
	if maps_size == 0:
		map_array.append("Something went wrong loading levels! None detected.-----")
		print("No levels detected what the frick???")
		print(str(map_files))
	
	return map_array

func get_ext_maps() -> Array:
	var ext_maps = DirAccess.get_files_at(ext_map_path)
	
	for file in ext_maps:
		ext_map_array.append(file)
	
	print("mod levels detected: " + str(ext_map_array.size()))
	print(str(ext_map_array))
	if ext_map_array.size() == 0:
		print("no mod maps detected")
	
	return ext_map_array

#func add_level_buttons() -> void:
#	map_index = 0
#	for level in maps:
#		ProjectSettings.load_resource_pack(map_dir + level)
#		# Create a new button in memory
#		var button = Button.new()
#		# Adds button to the levels_container node
#		levels_container.add_child(button)
#		# Takes the file's name and adds a number to the front of it according to the order
#		var button_text = str(maps[map_index])
#		# Strips the .tscn from the map's filename to put on the button for a cleaner look
#		button.text = button_text.left(-5)
#		# Connects the button's "pressed" signal to the script, attaching the button's data with it
#		button.pressed.connect(_on_level_button_pressed.bind(button))
#
#		map_index += 1

func add_ext_buttons() -> void:
	map_index = 0
	for file in ext_map_array:
		ProjectSettings.load_resource_pack(ext_map_path + file)
		var button = Button.new()
		levels_container.add_child(button)
		var button_text = str(ext_map_array[map_index])
		button.text = button_text.left(-4)
		button.pressed.connect(_on_ext_level_pressed.bind(button))
		
		map_index += 1

func remove_old_buttons() -> void:
	for button in levels_container.get_children():
		levels_container.remove_child(button)
		button.queue_free()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://maps/bigcity_level.tscn")
