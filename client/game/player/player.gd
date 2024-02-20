extends CharacterBody3D
var speed := 100.0
var acceleration := 4.0
var jump_speed := 8.0
var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var old_position = Vector3.ZERO
var old_rotation = Vector3.ZERO
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player_name := $player_name
@onready var player := $warrior_player
@onready var animation := $warrior_player/AnimationPlayer
@onready var player_info_label := $player_info_label
@onready var acton_area := $warrior_player/action_area
@onready var server = get_node("/root/Mietek/server")

func _physics_process(delta):
	check_position_and_rotation(delta)
	check_action_area(delta)
	input_acton(delta)
	velocity.y += - gravity * delta*2
	get_move_input(delta)
	_animation(delta)
	move_and_slide()

func input_acton(_delta:float):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)		
		get_node("/root/Mietek/start_window").show()
		get_parent().hide()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

func get_move_input(_delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("run_left", "run_right", "run_forward", "run_back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, twist_pivot.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * _delta)
	velocity.y = vy

	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	player.rotate_y(twist_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-30), 
		deg_to_rad(30)
	)
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func _animation(_delta):
	if velocity.length() > 1.5 and is_on_floor():
		animation.play("Run", -1, 0.1 * velocity.length())
	else:
		animation.play("onehand_idle", -1, 1)
		 
func check_position_and_rotation(_delta:float):
	if server.state_connection == server.DISCONNECTED:
		return
	if global_position != old_position or old_rotation != player.global_rotation:
		rpc("remote_set_position", [global_position, player.global_rotation])
		old_position = global_position
		old_rotation = player.global_rotation

func check_action_area(_delta:float):
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
			
