extends RigidBody3D
@onready var player := $warrior_player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_enemy_id(id:int):
	set_name(str(id))
	$name_label.set_text(get_name())

	
	
#@rpc("any_peer")
func set_player_position(g_pos:Vector3, rot:Vector3):
	global_position = g_pos
	player.global_rotation = rot

