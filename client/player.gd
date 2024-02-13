extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var speed := 1300
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player := $warrior_player
@onready var animation := $warrior_player/AnimationPlayer

var info_label = Label.new()

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:	
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
		var start_window = get_node("/root/game/start_window")
		var game = get_node("/root/game/game")
		start_window.show()
		game.hide()
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
