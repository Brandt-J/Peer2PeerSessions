extends Node
class_name NPCSpawner

var num_npcs: int = 50
var npc_node_path: String = "res://Characters/NPC.tscn"
var npcs: Array[NPC] = []
var idx_counter: int = 0
@export var extent: float = 20.0


func spawn_npcs() -> void:
	for i in range(num_npcs):
		_add_npc_add_random_position()


func _add_npc_add_random_position() -> void:
	var own_id: int = multiplayer.get_unique_id()
	var npc_name: String = "NPC_%s_%s" % [own_id, idx_counter]
	var rand_pos: Vector3 = Vector3(randf_range(-extent, extent), 0.5, randf_range(-extent, extent))
	var new_npc: NPC = NetworkManager.spawn_node(npc_node_path, npc_name, rand_pos)
	npcs.append(new_npc)
	idx_counter += 1


func _on_exchange_npc_timer_timeout():
	if npcs.size() > 0:
		var rand_npc: NPC = npcs.pick_random()
		npcs.erase(rand_npc)
		NetworkManager.remove_node(rand_npc)
		_add_npc_add_random_position()
	
