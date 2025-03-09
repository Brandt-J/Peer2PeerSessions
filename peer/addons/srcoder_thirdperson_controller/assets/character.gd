extends CharacterBody3D
class_name Character

@export_category("Player Movement")
@export var speed := 5.0
@export var jump_velocity := 4.5
const ROTATION_SPEED := 6.0

var direction: Vector3
var jumping: bool = false
var initial_transform_set: bool = false
@onready var playermodel : Node3D = $playermodel

enum animation_state {IDLE,RUNNING,JUMPING}
var animation_speed: float = 1.0
var player_animation_state : animation_state = animation_state.IDLE
@onready var _animation_player : AnimationPlayer = $"playermodel/character-male-e2/AnimationPlayer"


func _process(_delta: float) -> void:
	#tell the playeranimationcontroller about the animation state
	match player_animation_state:
		animation_state.IDLE:
			_animation_player.play("idle", -1, animation_speed)
		animation_state.RUNNING:
			_animation_player.play("sprint", -1, animation_speed)
		animation_state.JUMPING:
			_animation_player.play("jump", -1, animation_speed)
	

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if jumping and is_on_floor():
		velocity.y = jump_velocity

	if direction != Vector3():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		rotate_model(direction, delta)
		player_animation_state = animation_state.RUNNING
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		player_animation_state = animation_state.IDLE
	
	if not is_on_floor():
		player_animation_state = animation_state.JUMPING
	
	move_and_slide()
	
	
func rotate_model(direction: Vector3, delta : float) -> void:
	basis = lerp(basis, Basis.looking_at(direction), 10.0 * delta).orthonormalized()
