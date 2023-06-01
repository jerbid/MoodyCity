extends VehicleBody3D

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

# Coolant timers
@onready var coolant_timer := $CoolantTimer
@onready var temp_timer := $TempTimer

# The coolant detector area
@onready var coolant_area := $CoolantDetector

# Coolant variables
var jugs_left : int = 20
var coolant_left := 100
var time_start : int
var elapsed_time : int
var temp : int

func _ready():
	# On ready, all lights turn off
	headlights.visible = false
	reverse_lights.visible = false
	brake_lights.visible = false
	# Make sure pause menu is off
	pause_menu.visible = false
	# Make sure timers are started
	coolant_timer.timeout.connect(_on_coolant_Timer_timeout)
	temp_timer.timeout.connect(on_Temp_Timer_timeout)
	time_start = Time.get_ticks_msec()
	# Connect coolant detector's area_entered signal
	coolant_area.area_entered.connect(_on_Coolant_Area_area_entered)

func _physics_process(delta: float) -> void:
	set_springarm_pos()
	# Set steering to the axis between the steering controls
	steering = lerp(steering, Input.get_axis("steer_right", "steer_left") * 0.4, 2.0 * delta)
	# Set engine force to the axis between the forward and reverse controls, then multiplied by a force multiplier
	set_engine_force(Input.get_axis("accelerate", "reverse") * 7500)
	
	# Set brake force and turnbrake lights on when handbrake is pressed
	if Input.is_action_just_pressed("handbrake"):
		brake = 125
		brake_lights.visible = true
	elif Input.is_action_just_released("handbrake"):
		brake = 0
		brake_lights.visible = false
	
	# Logic for activating the reverse/brake lights for the reverse key
	var forward_velocity := (linear_velocity * global_transform.basis).z
	if forward_velocity > 0.3:
		reverse_lights.visible = true
	elif forward_velocity < 0.3 and Input.is_action_pressed("reverse"):
		brake_lights.visible = true
		reverse_lights.visible = false
	elif Input.is_action_pressed("accelerate") and forward_velocity < 0.3:
		brake_lights.visible = false
		reverse_lights.visible = false
	else:
		reverse_lights.visible = false
	
	# Debug text
	label.text = ("engine force: " + str(engine_force) + "\n forward_velocity " + 
	str((linear_velocity * global_transform.basis).z) + "\n brake force " + str(brake))

func _process(_delta) -> void:
	# Gets the time for the time label
	var time_now = Time.get_ticks_msec()
	elapsed_time = (time_now - time_start) / 1000
	var seconds = elapsed_time
	if seconds > 59:
		seconds = 0
	var minutes = elapsed_time / 60
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

# Logic for toggling headlights on and off
func toggle_headlights() -> void:
	headlights.visible = not headlights.visible
	
func set_springarm_pos() -> void:
	# Set the spring arm's location to that of the car's plus a slight rise to prevent floor clipping. 
	# Rotation is handled by the spring arm's script
	springarm.position = position
	springarm.position.y = position.y + .5

func toggle_pause_menu() -> void:
	pause_menu.visible = not pause_menu.visible
	if pause_menu.visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_ui.visible = false
		coolant_timer.stop()
		temp_timer.stop()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		game_ui.visible = true
		coolant_timer.start()
		temp_timer.start()

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

func _on_Coolant_Area_area_entered(_body: Area3D) -> void:
	temp -= 60
	if temp < 70:
		temp = 0
	elif temp < 0:
		temp = 0
	
	coolant_left += 50

# --------------------------------------------------------------------------------------------------------------
# Pause menu functions
# --------------------------------------------------------------------------------------------------------------
func _on_resume_pressed():
	# Since the pause menu is open when this button is visible, it will always close the menu. Theoretically.
	toggle_pause_menu()

func _on_main_menu_pressed():
	# Changes scene to main menu. Currently the main menu does not work lol.
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

# ---------------------------------------------------------------------------------------------------------------
