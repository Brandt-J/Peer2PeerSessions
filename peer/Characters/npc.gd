extends Character
class_name NPC

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _logger: Logging.Logger = Logging.get_logger("NPC")

func _ready():
	await get_tree().create_timer(0.5).timeout
	_set_new_navigation_target()


func _physics_process(delta: float) -> void:
	var target_pos: Vector3 = _nav_agent.get_next_path_position()
	if global_position.distance_to(target_pos) > 0.5:
		direction = global_position.direction_to(target_pos)
	else:
		direction = Vector3()
	super._physics_process(delta)


func _set_new_navigation_target():
	if is_multiplayer_authority():
		var extent: float = 10.0
		var target: Vector3 = Vector3(randf_range(-extent, extent), 0.0, randf_range(-extent, extent))
		_logger.debug("NPC %s with target %s" % [name, target])
		await get_tree().create_timer(0.5).timeout
		_nav_agent.set_target_position(target)
	
