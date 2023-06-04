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

var save_stats : MoodyCitySaveStats
var maps : Array
var map_index : int
var maps_size : int

func _ready():
	if load("res://moody_city_save.tres") == null:
		save_stats = MoodyCitySaveStats.new()
		save_stats.resource_path = save_stats.SAVE_PATH
		save_stats.save()
	else:
		save_stats = load("res://moody_city_save.tres")
	
	maps = get_maps()
	print("levels detected: " + str(maps_size) + "\nfiles: " + str(maps))
	add_level_buttons()

func _on_stats_pressed():
	title.visible = false
	main_buttons.visible = false
	stats.visible = true
	
	if save_stats.lowest_time == 9999999999:
		lowest_time.text = "Fastest win: You haven't won yet!"
	else:
		lowest_time.text = "Fastest win: " + save_stats.get_lowest_time_as_string()
	coolant_collected.text = "Total coolant jugs collected: " + str(save_stats.total_coolant_collected)
	living_temp.text = "Highest living temp: " + str(save_stats.highest_living_temp)
	losses.text = "Losses: " + str(save_stats.losses)
	wins.text = "Wins: " + str(save_stats.wins)
	
func _on_back_pressed():
	stats.visible = false
	levels.visible = false
	main_buttons.visible = true
	title.visible = true

func _on_play_game_pressed():
	get_tree().change_scene_to_file("res://maps/bigcity_level.tscn")

func _on_quit_game_pressed():
	get_tree().quit()

func _on_levels_pressed():
	main_buttons.visible = false
	levels.visible = true

func _on_level_button_pressed(button):
	get_tree().change_scene_to_file("res://maps/" + button.text)

func get_maps() -> Array:
	var map_array : Array
	var map_dir := DirAccess.get_files_at("res://maps")
	for file in map_dir:
		if file.get_extension() == "tscn":
			map_array.append(file)
	
	maps_size = map_array.size()
	if maps_size == 0:
		map_array.append("Something went wrong loading levels! None detected.")
		print("No levels detected what the frick???")
	
	return map_array

func add_level_buttons() -> void:
	for level in maps:
		var button = Button.new()
		levels_container.add_child(button)
		button.text = str(map_index + 1) + ". " + maps[map_index]
		button.pressed.connect(_on_level_button_pressed.bind(button))
		
		map_index += 1
