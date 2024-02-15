extends Control
@onready var info_label := $ColorRect/MarginContainer/VBoxContainer/login_container/info_label
@onready var login := $ColorRect/MarginContainer/VBoxContainer/login_container/login_input
@onready var password := $ColorRect/MarginContainer/VBoxContainer/login_container/password_input
@onready var login_container := $ColorRect/MarginContainer/VBoxContainer/login_container

@onready var main_container := $ColorRect/MarginContainer/VBoxContainer/main_container
@onready var connection_checkbox := $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/connection
@onready var options_container := $ColorRect/MarginContainer/VBoxContainer/options_cantainer
@onready var fps_options = $ColorRect/MarginContainer/VBoxContainer/options_cantainer/max_frame_option
var clear_timer := Timer.new()
var is_started = false

@onready var server = get_node("/root/Mietek/server")
@onready var game = get_node("/root/Mietek/Game")
@onready var enemy_player = load("res://game/enemy_player/enemy_player.tscn")

func _ready():
	info_label.hide()
	options_container.hide()
	main_container.hide()
	clear_timer.one_shot = true
	add_child(clear_timer)
	clear_timer.connect("timeout", on_timer_timeout)
	server.connect_to_server()
	
func _on_close_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	main_container.hide()
	options_container.show()

func _on_back_button_pressed():
	main_container.show()
	options_container.hide()

func _on_max_frame_option_item_selected(index):
	Engine.max_fps = int(fps_options.get_item_text(index))

func set_connection_checkbox(state:bool):
	connection_checkbox.button_pressed = state

func _on_connect_buton_pressed():
	info_label.show()
	clear_timer.stop()
	clear_timer.start(3)
	if login.text == "":
		info_label.set_text("Login cannot be empty")
		return
	if password.text == "":
		info_label.set_text("Password cannot be empty")
		return
	info_label.set_text("Trying to connect to the server...")
	if server.state_connection == server.DISCONNECTED:
		info_label.set_text("Cannot conect with server !!!")
		return
	rpc_id(1,"login_to_server",{"login":login.text, "password":password.text})
	info_label.set_text("Trying login to server ...")

@rpc
func login_to_server(_mess):pass

@rpc("authority","call_remote", "reliable")
func login_to_server_callback(login_state:int):
	login.set_text("")
	password.set_text("")
	if login_state == 1:
		info_label.set_text("Success")
		login_container.hide()
		main_container.show()
	elif login_state == 2:
		info_label.set_text("Login or password incorrect")
	elif login_state == 3:
		info_label.set_text("The account is already logged in")


func on_timer_timeout():
	info_label.set_text("")
	info_label.hide()

func _on_start_button_button_down():
	if not is_started:
		rpc_id(1,"start_game_server")
	hide()
	game.show()
	
@rpc("authority","call_remote", "reliable")
func start_game_server():pass

@rpc("authority","call_remote","reliable")
func start_game(player_in_game):
	#print(player_in_game)
	is_started = true
	for player in player_in_game:
		#print(player)
		if player == multiplayer.get_unique_id():
			continue
		var enemy_player_instance = enemy_player.instantiate()
		enemy_player_instance.set_enemy_id(player)
		game.add_child(enemy_player_instance)	
	rpc("new_player_join")
	hide()

@rpc("any_peer")
func new_player_join():
	if not is_started:
		return
	var enemy_player_instance = enemy_player.instantiate()
	var id := multiplayer.get_remote_sender_id()
	enemy_player_instance.set_enemy_id(id)
	game.add_child(enemy_player_instance)	

@rpc("authority")
func player_left_game(id):
	for child in game.get_children():
		if child.get_name() == str(id):
			game.remove_child(child)
