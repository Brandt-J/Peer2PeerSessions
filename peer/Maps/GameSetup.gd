extends Node3D
class_name GameMap


func get_free_spawn_location() -> Vector3:
	var spawn_location: Vector3
	var free_point_found: bool = false
	
	for spawn_point in get_tree().get_nodes_in_group("SpawnPoint"):
		spawn_point = spawn_point as Area3D
		if not spawn_point.has_overlapping_bodies():
			spawn_location = spawn_point.global_position
			free_point_found = true
			break
			
	assert(free_point_found)
	return spawn_location
