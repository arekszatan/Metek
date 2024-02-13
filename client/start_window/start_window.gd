extends Control

func _ready():
	pass

func _on_resume_button_pressed():	
	var game = get_node("/root/game/game")
	game.show()
	self.hide()

func _on_close_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	$ColorRect/MarginContainer/VBoxContainer/main_container.hide()
	$ColorRect/MarginContainer/VBoxContainer/options_cantainer.show()


func _on_back_button_pressed():
	$ColorRect/MarginContainer/VBoxContainer/main_container.show()
	$ColorRect/MarginContainer/VBoxContainer/options_cantainer.hide()


func _on_max_frame_option_item_selected(index):
	var options = $ColorRect/MarginContainer/VBoxContainer/options_cantainer/max_frame_option
	Engine.max_fps = int(options.get_item_text(index))



func _on_test_pressed():
	pass
	#Ser.start()
	#server._ready()
	#server.start()
	#print(server.SERVER_IP)
	#server.connect_to_server()

func set_connection_checkbox(state: bool):
	var connection_checkbox = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/connection
	connection_checkbox.button_pressed = state
