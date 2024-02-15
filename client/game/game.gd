extends Node3D

@onready var enemy_player = load("res://game/enemy_player/enemy_player.tscn")


func _ready():
	hide()
	#rpc("add_new_player")

func _process(_delta):
	if is_visible():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#@rpc("any_peer")
#func add_new_player():
	#var enemy_player_instance = enemy_player.instantiate()
	#get_parent().add_child(enemy_player_instance)	
	#var id := multiplayer.get_remote_sender_id()
	#rpc_id(id,"start_game",id)
	#print("add new player")


