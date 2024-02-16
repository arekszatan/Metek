extends Control

@onready var player_level_label := $VBoxContainer2/player_ui_bottom/MarginContainer/HBoxContainer/player_level_label
@onready var level_progress_bar := $VBoxContainer2/player_ui_bottom/MarginContainer/HBoxContainer/level_progress_bar
@onready var player_name_label := $VBoxContainer2/player_ui_bottom/MarginContainer/HBoxContainer/player_name_label
@onready var start_window = get_node("/root/Mietek/start_window")
@onready var game = get_node("/root/Mietek/Game")
@onready var player = get_node("/root/Mietek/Game/player")

func _ready():
	start_window.start_game_signal.connect(start_game)


func start_game(_name):
	set_player_name_label(_name)
	rpc_id(1, "get_player_state_server", player_name_label.get_text())

func set_player_level(level:String):
	player_level_label.set_text(level)

func set_player_name_label(_name:String):
	player_name_label.set_text(_name)
	player.player_name.set_text(_name)

func set_level_progress_bar(value:float):
	level_progress_bar.set_value(value)
	
@rpc
func get_player_state_server(_name):pass

@rpc
func set_player_state(data):
	set_level_progress_bar(data[0]["level_per"])
	set_player_level(str(data[0]["levels"]))
	rpc("emit_player_name",player_name_label.get_text())

@rpc("any_peer","call_remote","reliable")
func emit_player_name(_name):
	var id = multiplayer.get_remote_sender_id()
	for child in game.get_children():
		if child.get_name() == str(id):
			child.set_enemy_name(_name)
	rpc_id(id,"callback_set_player_name", player_name_label.get_text())

@rpc("any_peer","call_remote","reliable")
func callback_set_player_name(_name):
	var id = multiplayer.get_remote_sender_id()
	for child in game.get_children():
		if child.get_name() == str(id):
			child.set_enemy_name(_name)
