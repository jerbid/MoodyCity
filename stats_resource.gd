class_name MoodyCitySaveStats
extends Resource

const SAVE_PATH := "res://moody_city_save.tres"

# Stores lowest time as integer, lowest_time_as_string() converts it into displayable text
# It starts as 10 nines just to help the Player.gd code work better
@export var lowest_time : int = 9999999999
# Stores total amount of coolant collected over all time
@export var total_coolant_collected : int
# Stores highest temp attained before collecting coolant
@export var highest_living_temp : int
# Stores total losses
@export var losses : int
# Stores total wins
@export var wins : int

func save():
	ResourceSaver.save(self)

func get_lowest_time_as_string() -> String:
	var minutes : int = lowest_time / 60
	var seconds : int = lowest_time & 60
	var lowest_time_as_string : String = str(minutes) + "m " + str(seconds) + "s"
	return lowest_time_as_string
