extends Node3D
class_name GameMap


var playerScene: PackedScene = preload("res://addons/srcoder_thirdperson_controller/player.tscn")
var spawnable_scenes: Array[String] = ["res://addons/srcoder_thirdperson_controller/player.tscn"]
#var _spawners: Dictionary[int, MultiplayerSpawner] = {}
var _local_player_spawned: bool = false

	
#func _process(_delta: float) -> void:
	#if not _local_player_spawned:
		#try_spawning_local_player()
	
	#var txt: String = ""
	#for spawner_id in _spawners:
		#txt += "Spawner %s: " % spawner_id
		#for child in _spawners[spawner_id].get_children():
			#txt += "%s, " % child.name
		#txt += "\n"
	#$Label.text = txt
		

#func try_spawning_local_player() -> void:
	#var player_id: int = multiplayer.get_unique_id()
	#if not player_id in _spawners:
		#print("Local spawner not yet present")
		#return
	
	#print("Spawning local player for id ", player_id)
	##var spawner: MultiplayerSpawner = _spawners[player_id]
	#var loc: Vector3 = _get_free_spawn_location()
	#var new_player: Player = playerScene.instantiate()
	#new_player.name = "Player %s" % player_id
	
	
	
	#spawner.add_child(new_player)
	#new_player.set_owner(spawner)
	
	#new_player.global_position  = loc
	#new_player.set_multiplayer_authority(player_id)
	#new_player.activate()
	#_local_player_spawned = true


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


#func update_spawners(connected_peers: Array[int]) -> void:
	## cleanup not used ones
	#for id in _spawners.keys():
		#if id not in connected_peers:
			#_spawners[id].queue_free()
			#_spawners.erase(id)
	#
	## create new ones
	#var newSpawner: MultiplayerSpawner
	#for id in connected_peers:
		#if id not in _spawners:
			#newSpawner = MultiplayerSpawner.new()
			#newSpawner.name = "Spawner %s" % id
			#%MultiplayerSpawners.add_child(newSpawner)
			#newSpawner.set_owner(%MultiplayerSpawners)
			#newSpawner.set_multiplayer_authority(id)
			#newSpawner.spawn_path = newSpawner.get_path()
			#newSpawner.spawned.connect(_notify_spawn)
			#for scene_path in spawnable_scenes:
				#newSpawner.add_spawnable_scene(scene_path)
			#
			#_spawners[id] = newSpawner
			#print("On %s: Created spawner %s" % [multiplayer.get_unique_id(), id])
#
#
#func _notify_spawn(node: Node) -> void:
	#print("Spawned %s on id %s " % [node.name, multiplayer.get_unique_id()])
