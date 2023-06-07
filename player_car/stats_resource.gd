class_name MoodyCitySaveStats
extends Resource

# ------------------------------
# The Save Stats resource script
# ------------------------------
# 
# This script defines what is saved in the save stats and 
# provides a path + save function.
#
# ------------------------------

# The path where save data is saved.
const SAVE_PATH := "user://moody_city_save.tres"

# The time the file was created
@export var time_created : String
# Stores lowest time as integer, lowest_time_as_string() converts it into displayable text
# It starts as 10 nines just to help the Player.gd code work better
@export var lowest_time : int = 99999999
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
