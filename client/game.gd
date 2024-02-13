extends Node3D

func _ready():
	hide()

func _process(delta):
	if is_visible():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
