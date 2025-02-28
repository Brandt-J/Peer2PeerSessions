extends Node
class_name NPCSpawner

var num_npcs: int = 50
var npc_node_path: String = "res://Characters/NPC.tscn"
@export var extent: float = 5.0


func spawn_npcs() -> void:
	var npc_name: String
	var own_id: int = multiplayer.get_unique_id()
	var rand_pos: Vector3
	for i in range(num_npcs):
		npc_name = "NPC_%s_%s" % [own_id, i]
		rand_pos = Vector3(randf_range(-extent, extent), 0.5, randf_range(-extent, extent))
		NetworkManager.spawn_node(npc_node_path, npc_name, rand_pos)
