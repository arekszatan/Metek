extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var speed := 1300
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player := $warrior_player
@onready var animation := $warrior_player/AnimationPlayer
@onready var player_info_label := $player_info_label
@onready var player_name := $player_name
@onready var acton_area := $warrior_player/action_area
@onready var colision_action_area := $warrior_player/action_area/colision_action_area

@onready var server = get_node("/root/Mietek/server")
var old_position = Vector3.ZERO
var old_rotation = 0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:	
	movement(delta)
	input_acton(delta)
	check_position_and_rotation(delta)
	check_action_area(delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func movement(delta:float):
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
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	player.rotate_y(twist_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-30), 
		deg_to_rad(30)
	)
	twist_input = 0.0
	pitch_input = 0.0

func input_acton(delta:float):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)		
		get_node("/root/Mietek/start_window").show()
		get_parent().hide()

func check_position_and_rotation(delta:float):
	if server.state_connection == server.DISCONNECTED:
		return
	if global_position != old_position or old_rotation != player.global_rotation:
		rpc("remote_set_position", [global_position, player.global_rotation])
		old_position = global_position
		old_rotation = player.global_rotation

func check_action_area(delta:float):
	#print(twist_input)
	var objects = acton_area.get_overlapping_bodies()
	player_info_label.set_text("")
	for object in objects:
		if not object.has_method("set_enemy_info_label"):
			continue
		player_info_label.set_text("Action with [ %s ]"%[object.get_enemy_name()])
		object.set_enemy_info_label("Press [e] to call the action")
		if not object.has_method("action_with_player"):
			continue
		if Input.is_action_just_pressed("player_action"):
			object.action_with_player()
		break
	
	
@rpc("any_peer", "call_remote", "unreliable")
func remote_set_position(pos_and_rot):
	var id := multiplayer.get_remote_sender_id()
	for child in get_parent().get_children():
		if child.get_name() == str(id):
			child.set_player_position(pos_and_rot[0], pos_and_rot[1])
