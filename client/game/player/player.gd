extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var speed := 1300
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player := $warrior_player
@onready var animation := $warrior_player/AnimationPlayer

@onready var server = get_node("/root/Mietek/server")
var old_position = Vector3.ZERO
var old_rotation = 0

var info_label = Label.new()

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:	
	#print(multiplayer.get_peers())
	#if not is_multiplayer_authority():
		#return
	var input := Vector3.ZERO
	input.x = Input.get_axis("run_left", "run_right")
	input.z = Input.get_axis("run_forward", "run_back")
	if input == Vector3.ZERO:
		animation.play("onehand_idle")
		linear_damp = 10	
	if input.z < 0:
		animation.play("Run", -1, 0.8)
		linear_damp = 1
	apply_central_force(twist_pivot.basis * input * speed * delta)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)		
		get_node("/root/Mietek/start_window").show()
		get_parent().hide()
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	player.rotate_y(twist_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-30), 
		deg_to_rad(30)
	)
	twist_input = 0.0
	pitch_input = 0.0
	#print(multiplayer.has_multiplayer_peer()
	if server.state_connection == server.DISCONNECTED:
		return
	#print(global_position, old_position, player.global_rotation, old_rotation)
	if global_position != old_position or old_rotation != player.global_rotation:
		#print([global_position, player.global_rotation])
		rpc("remote_set_position", [global_position, player.global_rotation])
		old_position = global_position
		old_rotation = player.global_rotation

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

@rpc("any_peer", "call_remote", "unreliable")
func remote_set_position(pos_and_rot):
	#print("change pos")
	var children = get_parent().get_children()
	var id := multiplayer.get_remote_sender_id()
	#print(get_parent().find_child(str(id)))
	for child in children:
		if child.get_name() == str(id):
			child.set_player_position(pos_and_rot[0], pos_and_rot[1])
	#print(get_parent().get_child())
