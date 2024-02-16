extends RigidBody3D

@onready var player := $warrior_player
@onready var player_info_label := $enemy_info_label
@onready var name_label := $name_label
var clear_timer := Timer.new()

func _ready():
	clear_timer.one_shot = true
	add_child(clear_timer)
	clear_timer.connect("timeout", on_timer_timeout)

func _process(_delta):
	pass

func set_enemy_id(id:int):
	set_name(str(id))

func set_enemy_name(_name:String):
	name_label.set_text(_name)

func get_enemy_name():
	return name_label.get_text()

func set_player_position(g_pos:Vector3, rot:Vector3):
	global_position = g_pos
	player.global_rotation = rot

func on_timer_timeout():
	player_info_label.set_text("")

func set_enemy_info_label(text:String):
	player_info_label.set_text(text)
	clear_timer.stop()
	clear_timer.start(0.1)
	
func action_with_player():
	print("action")

