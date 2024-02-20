extends Node

@onready var db := get_node("/root/Mietek/database")

@rpc("any_peer","call_remote","reliable")
func get_player_state_server(_name):
	var query = "SELECT levels, level_per FROM accounts JOIN player_state on 
	accounts.player_state = player_state.id WHERE name='%s';"%[_name]
	var id = multiplayer.get_remote_sender_id()
	rpc_id(id,"set_player_state", db.custom_select(query))

@rpc("any_peer","call_remote","reliable")
func set_player_state(_data):pass
@rpc("any_peer","call_remote","reliable")
func emit_player_name(_name):pass
@rpc("any_peer","call_remote","reliable")
func callback_set_player_name(_name):pass
