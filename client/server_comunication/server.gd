extends Node
var multiplayer_peer 
const PORT = 10001
const IP_ADDRESS = "127.0.0.1"
var connected_player = []
enum {CONNECTED, DISCONNECTED}
var state_connection = DISCONNECTED

func _ready():
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.connected_to_server.connect(player_connected)
	multiplayer.server_disconnected.connect(player_disconnected)
	var error = multiplayer_peer.create_client(IP_ADDRESS, PORT)
	if error != OK:
		print("Cannot connect with server ", IP_ADDRESS, " and PORT ", PORT, " error is ", error)
		return
	multiplayer_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(multiplayer_peer)

func connect_to_server():
	pass
	
func player_connected():
	print("Connected with serwer ", IP_ADDRESS, " and PORT ", PORT)
	var start_window = get_node("/root/game/start_window")
	start_window.set_connection_checkbox(true)
	state_connection = CONNECTED
	send_info_to_server("czesc")
	#print("player connected with server ", id)
	#rpc("transfer_some_input")

func player_disconnected():
	print("Disconnected with serwer ", IP_ADDRESS, " and PORT ", PORT)	
	var start_window = get_node("/root/game/start_window")
	start_window.set_connection_checkbox(false)
	state_connection = DISCONNECTED

func _process(delta):
	pass
	#if state_connection == DISCONNECTED:
		#pass

func send_info_to_server(mess):
	rpc("get_info_from_client", mess)
	
@rpc("call_local")
func get_info_from_client(mess):pass
