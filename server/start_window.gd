extends Node

@onready var db := get_node("/root/Mietek/database")
@onready var players_logged := get_node("/root/Mietek/ColorRect/HBoxContainer/players_logged")
@onready var players_in_game := get_node("/root/Mietek/ColorRect/HBoxContainer/players_in_game")
@onready var game = load("res://game/Game.tscn")
var players_in_game_array = []
var logged_players_array = []

@rpc("any_peer","call_remote","reliable")
func login_to_server(mess):
	var login = mess["login"]
	var password = mess["password"]
	var result = db.select_data("accounts",
	"login='%s' AND password='%s'"%[login,password],["*"])
	var id := multiplayer.get_remote_sender_id()
	print(logged_players_array)
	var login_in_use = false
	for loged_player in logged_players_array:
		if loged_player["login"] == login:
			login_in_use = true
	var is_logged = -1
	if len(result) > 0 and not login_in_use:
		is_logged = 1
	elif len(result) == 0:
		is_logged = 2 
	elif login_in_use:
		is_logged = 3	
	if is_logged == 1:
		logged_players_array.append({"id":id,"login":login})
		var new_label = Label.new()
		new_label.set_text("%s -> %s"%[login, str(id)])
		new_label.set_name(str(id))
		players_logged.add_child(new_label)
		print("New player with id %s is logged to the game"%[id])
	rpc_id(id, "login_to_server_callback",is_logged)

@rpc
func login_to_server_callback(_is_login):pass
	
@rpc("any_peer","call_remote","reliable")
func start_game_server():
	var id := multiplayer.get_remote_sender_id()
	players_in_game_array.append(id)
	var new_label = Label.new()
	new_label.set_text(str(id))
	new_label.set_name(str(id))
	players_in_game.add_child(new_label)
	rpc_id(id,"start_game", players_in_game_array)

@rpc
func start_game(_player_in_game):pass

@rpc("any_peer")
func new_player_join():
	var id := multiplayer.get_remote_sender_id()
	print("New player %s is join to game !"%[id])

func player_left_game_server(id):
	for child in players_logged.get_children():
		if child.get_name() == str(id):
			players_logged.remove_child(child)
	for child in players_in_game.get_children():
		if child.get_name() == str(id):
			players_in_game.remove_child(child)
	for i in logged_players_array.size():
		if logged_players_array[i]["id"] == id:
			logged_players_array.remove_at(i) 
			break
	if logged_players_array.find(id) != -1:
		logged_players_array.remove_at(logged_players_array.find(id))
	if players_in_game_array.find(id) != -1:
		players_in_game_array.remove_at(players_in_game_array.find(id))
	print("Player %s remove from game on server side "%[id])
	rpc("player_left_game",id)

@rpc
func player_left_game(_id):pass
