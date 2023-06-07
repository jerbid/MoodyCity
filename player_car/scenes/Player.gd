extends VehicleBody3D

# ------------------------------
# The Player Script
# ------------------------------
#
# This script handles everything from the UI, stats saving, and most of the gameplay
# (movement, detecting coolant, light toggles)
#
# Each section of functions (game processes like _process(), general functions, signals, etc)
# are separated in boxes and should have comments throughout the big functions.
#
# Movement is handled in _physics_process(), UI is mostly in the signals section, win/lose functions
# are defined in general gameplay, and conditions for detecting coolant and saving stats are in signals.
#
# Sections in order:
#	1. Game start functions
#	2. General game functions
#	3. Signals
#
# ------------------------------

@export var save_stats : MoodyCitySaveStats

@export var mouse_sensitivity := 0.05

# The camera's spring arm
@onready var springarm := $SpringArm3D

# Variables for controlling the lights
@onready var headlights := $Lights/Headlights
@onready var reverse_lights := $Lights/ReverseLights
@onready var brake_lights := $Lights/Brakelights

# UI nodes
@onready var label := $CanvasLayer/debug_info
@onready var pause_menu := $CanvasLayer/PauseMenu

@onready var game_ui := $CanvasLayer/GameUI
@onready var jugs_label := $CanvasLayer/GameUI/MarginContainer/VBoxContainer/CoolantCans
@onready var time_label := $CanvasLayer/GameUI/MarginContainer/VBoxContainer/TimeLabel
@onready var temp_label := $CanvasLayer/GameUI/MarginContainer/VBoxContainer/Temp
@onready var coolant_bar := $CanvasLayer/GameUI/MarginContainer/VBoxContainer/ProgressBar
@onready var win_or_lose = $CanvasLayer/WinOrLose
@onready var win_screen = $CanvasLayer/WinOrLose/WinGreen
@onready var lose_screen = $CanvasLayer/WinOrLose/LoseRed

# Timers
@onready var coolant_timer := $CoolantTimer
@onready var temp_timer := $TempTimer
@onready var time_timer = $TimeTimer

# The coolant detector area
@onready var coolant_area := $CoolantDetector

# Coolant variables
var jugs_left : int = 20
var coolant_left := 100
var time_start : int
var elapsed_time : int
var temp : int
var win_temp : int

# Time variable
var seconds = 0
var minutes = elapsed_time / 60


func _ready():
	# If there's no save data found, create a new one in the same path.
	# Otherwise, it just loads the existing one.
	# res:// should be changed to user:// if building.
	# NOTE: This code also exists in the main menu script, this is because
	# the main menu scene does not have a Player.tscn
	if load("user://moody_city_save.tres") == null:
		save_stats = MoodyCitySaveStats.new()
		save_stats.resource_path = save_stats.SAVE_PATH
		save_stats.save()
	else:
		save_stats = load("user://moody_city_save.tres")
	# On ready, all lights turn off
	headlights.visible = false
	reverse_lights.visible = false
	brake_lights.visible = false
	# Make sure pause menu is off
	pause_menu.visible = false
	# Make sure timers are started
	coolant_timer.timeout.connect(_on_coolant_Timer_timeout)
	temp_timer.timeout.connect(on_Temp_Timer_timeout)
	time_timer.timeout.connect(_on_Time_Timer_timeout)
	# Connect coolant detector's area_entered signal
	coolant_area.area_entered.connect(_on_Coolant_Area_area_entered)
	
# ---------------------------------- End of game start functions -----------------------------------------------

# --------------------------------------------------------------------------------------------------------------
# Physics process, runs 60 times per frame to sync physics together
# --------------------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	set_springarm_pos()
	# Set steering to the axis between the steering controls
	steering = lerp(steering, Input.get_axis("steer_right", "steer_left") * 0.4, 2.0 * delta)
	# Set engine force to the axis between the forward and reverse controls, then multiplied by a force multiplier
	set_engine_force(Input.get_axis("accelerate", "reverse") * 7500)
	
	# Logic for activating the reverse lights for the reverse key
	var forward_velocity := (linear_velocity * global_transform.basis).z
	if forward_velocity > 0.3:
		reverse_lights.visible = true
	elif forward_velocity < 0.3 and Input.is_action_pressed("reverse"):
		reverse_lights.visible = false
	else:
		reverse_lights.visible = false
	
	# Logic for activating brake lights for the reverse key
	if Input.is_action_pressed("reverse") and forward_velocity < 0.4 or Input.is_action_pressed("accelerate") and forward_velocity > 0.4 or Input.is_action_pressed("handbrake"):
		brake_lights.visible = true
	else:
		brake_lights.visible = false
	
	# Set brake force and turnbrake lights on when handbrake is pressed
	if Input.is_action_just_pressed("handbrake"):
		brake = 125
	elif Input.is_action_just_released("handbrake"):
		brake = 0
	
	# Debug text
	label.text = (" engine force: " + str(engine_force) + "\n forward_velocity " + 
	str((linear_velocity * global_transform.basis).z) + "\n brake force " + str(brake)) + "\n fps: " + str(Performance.get_monitor(Performance.TIME_FPS))

# ------------------------- End of physics process -------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------
# Process function, calculations run every frame
# --------------------------------------------------------------------------------------------------------------

func _process(_delta) -> void:
	time_label.text = "Time: " + str(minutes) + "m " + str(seconds) + "s"
	# Set the values for the temperature and amount of jugs left labels
	temp_label.text = "Temp: " + str(temp) + " C"
	jugs_label.text = "Coolant jugs left: " + str(jugs_left)
	
	if position.y < -20:
		position = Vector3.ZERO
		print("lol imagine falling off the map, couldn't be me")
	
	# Ensures the temperature never goes below 0 and percentage of coolant left never reaches above 100%
	if temp < 0:
		temp = 0
	if coolant_left > 100:
		coolant_left = 100
		
# ------------------------- End of physics process -------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------
# Unhandled input, this function is for any input not already handled by other functions
# --------------------------------------------------------------------------------------------------------------
func _unhandled_input(event):
	# Toggles headlights
	if event.is_action_pressed("headlights"):
		toggle_headlights()
		# Toggles pause menu
	elif event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()
		# Emergency jump for when you get stuck
	elif event.is_action_pressed("debug_fly"):
		apply_impulse(Vector3(0, 999, 0), Vector3(0, 0, 15))
	elif event.is_action_pressed("ui_text_delete"):
		jugs_left -= 1
	
	# Captures mouse if it clicks in the game window and turns the camera based on mouse movement
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# I'll be real with you I got this all from a GDQuest video I don't totally know what it does
			springarm.rotation_degrees.x -= event.relative.y * mouse_sensitivity
			springarm.rotation_degrees.x = clamp(springarm.rotation_degrees.x, -90.0, 50.0)
			
			springarm.rotation_degrees.y -= event.relative.x * mouse_sensitivity
			springarm.rotation_degrees.y = wrapf(springarm.rotation_degrees.y, 0.0, 360.0)
	
	if event.is_action_pressed("scroll_down") and springarm.spring_length < 50:
		springarm.spring_length += 1
	elif event.is_action_pressed("scroll_up") and springarm.spring_length > 3:
		springarm.spring_length -= 1

# --------------------------------- End of unhandled input -----------------------------------------------------

# --------------------------------------------------------------------------------------------------------------
# General game functions
# --------------------------------------------------------------------------------------------------------------

# Logic for toggling headlights on and off
func toggle_headlights() -> void:
	headlights.visible = not headlights.visible

# Set the spring arm's location to that of the car's plus a slight rise to prevent floor clipping. 
# Rotation is handled by the spring arm's script
func set_springarm_pos() -> void:
	springarm.position = position
	springarm.position.y = position.y + .5

# Toggles the pause menu 
func toggle_pause_menu() -> void:
	# Checks if win/lose screen is open, and if not, allow user to toggle pause menu.
	if win_or_lose.visible == false:
		pause_menu.visible = not pause_menu.visible
	
	# If it's visible, the game stats UI disappears, frees the mouse, and pauses the game
	if pause_menu.visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_ui.visible = false
		coolant_timer.stop()
		temp_timer.stop()
		print("pause menu open")
		get_tree().paused = true
	
	# When it isn't, the game stops being paused, captures the mouse, and redraws the gaame stats UI
	else:
		get_tree().paused = false
		print("pause menu closed")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		game_ui.visible = true
		coolant_timer.start()
		temp_timer.start()

func show_win() -> void:
	# Announce win to console and save to stats
	print("you won lol imagine")
	save_stats.wins += 1
	if elapsed_time < save_stats.lowest_time:
		save_stats.lowest_time = elapsed_time
	if win_temp > save_stats.highest_living_temp:
		save_stats.highest_living_temp = win_temp
	save_stats.save()
	# Frees the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Stop timers
	temp_timer.stop()
	time_timer.stop()
	coolant_timer.stop()
	# Enable the win/lose screens node and ensure the win screen shows
	win_or_lose.visible = true
	lose_screen.visible = false
	win_screen.visible = true
	# Pause the game when win is shown
	get_tree().paused = true

func show_lose() -> void:
	# Announce loss in console and save to stats
	print("you lost lol imagine")
	save_stats.losses += 1
	save_stats.save()
	# Frees the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Stop timers
	temp_timer.stop()
	time_timer.stop()
	coolant_timer.stop()
	# Enable the win/lose screens node and ensure the lose screen shows
	win_or_lose.visible = true
	win_screen.visible = false
	lose_screen.visible = true
	# Pause the game when lose is shown
	get_tree().paused = true

func get_time_as_string() -> String:
	var time_as_string := str(minutes) + "m " + str(seconds) + "s"
	return time_as_string
	

# ----------------------------------- End of general game functions --------------------------------------------

# --------------------------------------------------------------------------------------------------------------
# Signals
# --------------------------------------------------------------------------------------------------------------

func _on_coolant_Timer_timeout() -> void:
	coolant_left -= 1
	coolant_bar.value = coolant_left

func on_Temp_Timer_timeout() -> void:
	if coolant_left > 97:
		pass
	elif coolant_left <= 97 and coolant_left > 66:
		temp += 1
	elif coolant_left < 66 and coolant_left > 33:
		temp += 2
	elif coolant_left < 33 and coolant_left > 10:
		temp += 3
	else:
		temp += 5
	
	if temp >= 200:
		show_lose()

func _on_Coolant_Area_area_entered(area: Area3D) -> void:
	if area.is_in_group("regular_coolant"):
		coolant_left += 50
		jugs_left -= 1
		
		if jugs_left == 0:
			win_temp = temp
		
		if temp < 70:
			temp = 0
		else:
			temp -= 60
			
		save_stats.total_coolant_collected += 1
		save_stats.save()
		
		print("regular_coolant gathered, jugs left minus 1 and temp is lowered to " + str(temp))
	if jugs_left == 0:
		show_win()

func _on_Time_Timer_timeout() -> void:
	# Gets the total time
	elapsed_time += 1
	seconds += 1
	minutes = elapsed_time / 60
	if seconds > 59:
		seconds = 0


# Pause menu functions
func _on_resume_pressed():
	# Since the pause menu is open when this button is visible, it will always close the menu. Theoretically.
	toggle_pause_menu()
	print("pressed resume")
	
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("pressed restart")
	
func _on_main_menu_pressed():
	# Unpauses and changes scene to main menu. Currently the main menu does not work lol.
	get_tree().paused = false
	print("going to main menu")
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_pressed():
	print("quitting game. see ya later")
	get_tree().quit()

# Win and Lose UI functions
func _on_play_again_pressed():
	get_tree().paused = false
	print("playing again")
	get_tree().reload_current_scene()

func _on_quit_game_pressed():
	print("quitting game. see ya later")
	get_tree().quit()

# -----------------------------  End of signals ----------------------------------------------------------------
