extends Node

var multiplayer_peer 
const PORT := 10001
const MAX_PLAYERS := 5
@onready var start_window = get_node("/root/Mietek/start_window")

func _ready():
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	var error = multiplayer_peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		print("Cannot host server on port ", PORT, " error is ", error)
		return
	print("Server is started on port ", PORT)
	multiplayer_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(multiplayer_peer)
	print("Waiting for player...")

func player_connected(id):
	print("Player with id %d connected"%[id])

func player_disconnected(id):
	print("Player with id %d disconnected"%[id])
	start_window.player_left_game_server(id)
