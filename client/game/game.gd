extends Node3D

@onready var enemy_player = load("res://game/enemy_player/enemy_player.tscn")
@onready var player_ui = get_node("/root/Mietek/Game/PlayerUi")

func _ready():
	hide()

func _process(_delta):
	player_ui.hide()
	if is_visible():
		player_ui.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
