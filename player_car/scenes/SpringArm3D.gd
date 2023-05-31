extends SpringArm3D

@export var sensitivity := 0.05

func _ready():
	set_as_top_level(true)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation_degrees.x -= event.relative.y * sensitivity
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 50.0)
			
			rotation_degrees.y -= event.relative.x * sensitivity
			rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _input(event):
	if event.is_action_pressed("scroll_down") and spring_length < 50:
		spring_length += 1
	elif event.is_action_pressed("scroll_up") and spring_length > 3:
		spring_length -= 1
