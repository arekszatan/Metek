extends Node

var multiplayer_peer 
const PORT = 10001
const MAX_PLAYERS = 5
var connected_player = []

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
	print("Player connected ", id)
	connected_player.append({
		"id_player":id,
		"name":""
	})
	#rpc("transfer_some_input")

func player_disconnected(id):
	print("Player disconnected ", id)
	
@rpc("call_local")
func transfer_some_input():
	print("start")

@rpc("any_peer")
func get_info_from_client(mess):
	print(mess)






