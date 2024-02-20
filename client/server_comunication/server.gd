extends Node
var multiplayer_peer 
const PORT = 10001
#const IP_ADDRESS = "35.159.52.8"
#const IP_ADDRESS = "127.0.0.1"
const IP_ADDRESS = "192.168.1.103"
var connected_player = []
enum {CONNECTED, DISCONNECTED}
var state_connection = DISCONNECTED
var reconnect_timer := Timer.new()

func _ready():
	reconnect_timer.connect("timeout", reconnect_to_server)
	add_child(reconnect_timer)
	
func connect_to_server():
	multiplayer_peer = ENetMultiplayerPeer.new() 
	multiplayer.connected_to_server.connect(player_connected)
	multiplayer.server_disconnected.connect(player_disconnected)
	var error = multiplayer_peer.create_client(IP_ADDRESS, PORT)
	if error != OK:
		print("Cannot connect with server ", IP_ADDRESS, " and PORT ", PORT, " error is ", error)
		reconnect_timer.start(5)
		return 
	multiplayer_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(multiplayer_peer)
	
func player_connected():
	print("Connected with serwer ", IP_ADDRESS, " and PORT ", PORT)
	var start_window = get_node("/root/Mietek/start_window")
	start_window.set_connection_checkbox(true)
	state_connection = CONNECTED
	reconnect_timer.stop()
	
func player_disconnected():
	print("Disconnected with serwer ", IP_ADDRESS, " and PORT ", PORT)	
	var start_window = get_node("/root/Mietek/start_window")
	start_window.set_connection_checkbox(false)
	state_connection = DISCONNECTED
	reconnect_timer.start(5)

func reconnect_to_server():
	print("Reconnect with serwer ", IP_ADDRESS, " and PORT ", PORT)
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_client(IP_ADDRESS, PORT)
	if error != OK:
		print("Cannot connect with server ", IP_ADDRESS, " and PORT ", PORT, " error is ", error)
		return 
	multiplayer_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(multiplayer_peer)
	
