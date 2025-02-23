extends CharacterBody3D
class_name Player

@export_category("Player Movement")
@export var speed := 5.0
@export var jump_velocity := 4.5
const ROTATION_SPEED := 6.0

#slowly rotate the charcter to point in the direction of the camera
@onready var camera : CameraPivot = $Camera
@onready var playermodel : Node3D = $playermodel

enum animation_state {IDLE,RUNNING,JUMPING}
var player_animation_state : animation_state = animation_state.IDLE
@onready var _animation_player : AnimationPlayer = $"playermodel/character-male-e2/AnimationPlayer"
@onready var _npc_spawner: NPCSpawner = $NpcSpawner
@onready var _synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer


func _ready() -> void:
	camera.set_target(self)
	

func activate() -> void:
	camera.activate()
	_npc_spawner.spawn_npcs()
	_synchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
	

func _process(_delta: float) -> void:
	#tell the playeranimationcontroller about the animation state
	match player_animation_state:
		animation_state.IDLE:
			_animation_player.play("idle")
		animation_state.RUNNING:
			_animation_player.play("sprint")
		animation_state.JUMPING:
			_animation_player.play("jump")
	

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (camera.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		#now rotate the model
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
	#rotate the model to match the springarm
	basis = lerp(basis, Basis.looking_at(direction), 10.0 * delta).orthonormalized()
