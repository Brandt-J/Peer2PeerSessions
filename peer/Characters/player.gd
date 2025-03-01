extends Character
class_name Player


@onready var _camera : CameraPivot = $Camera
@onready var _npc_spawner: NPCSpawner = $NpcSpawner


func _ready() -> void:
	_camera.set_target(self)
	

func activate() -> void:
	_camera.activate()
	_npc_spawner.spawn_npcs()
	#_synchronizer.set_multiplayer_authority(multiplayer.get_unique_id())


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		super._physics_process(delta)
		return
		
	# Handle jump.
	jumping = Input.is_action_just_pressed("ui_accept")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = (_camera.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	super._physics_process(delta)
