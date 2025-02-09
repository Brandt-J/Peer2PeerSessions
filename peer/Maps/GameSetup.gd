extends Node3D
class_name GameMap


var playerScene: PackedScene = preload("res://addons/srcoder_thirdperson_controller/player.tscn")
@onready var spawner = $MultiplayerSpawner

	

func set_authority(authority_id: int) -> void:
	spawner.set_multiplayer_authority(authority_id)
	

@rpc("any_peer", "call_local")
func _spawn_player(player_id: int) -> void:
	print("Spawning player %s, spawner has authority: %s" % [player_id, spawner.get_multiplayer_authority() == multiplayer.get_unique_id()])
	
	var loc: Vector3 = _get_free_spawn_location()
	var new_player: Player = playerScene.instantiate()
	new_player.name = "Player %s" % player_id
	spawner.add_child(new_player)
	new_player.set_owner(spawner)
	
	new_player.global_position  = loc
	new_player.set_multiplayer_authority(player_id)
	if player_id == multiplayer.get_unique_id():
		new_player.activate()


func _get_free_spawn_location() -> Vector3:
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
