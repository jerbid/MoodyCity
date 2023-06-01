extends Node3D

func _on_area_3d_area_entered(_area):
	print("coolant collected, see ya later alligator")
	queue_free()
