extends Node
class_name NodeReplicator


var _replicated_nodes: Dictionary[int, Dictionary] = {}  # {playerID, Dict: {nodeID: Node}
var _connected_peers: Array[int] = []
var _new_node_id: int = 0
var _node_templates: Dictionary[String, PackedScene] = {}


func update_connected_peers(connected_peers: Array[int]) -> void:
	_connected_peers = connected_peers
	for id in connected_peers:
		if id not in _replicated_nodes:
			_replicated_nodes[id] = {}



func spawn_node(node_path: String, authority_id: int, node_name: String) -> Node:
	_spawn_replicated_node(node_path, authority_id, node_name, _new_node_id)
	for id in _connected_peers:
		if id != multiplayer.get_unique_id():
			rpc_id(id, "_spawn_replicated_node", node_path, authority_id, _new_node_id)
	var spawned_node: Node = _replicated_nodes[authority_id][_new_node_id]
	_new_node_id += 1
	return spawned_node


@rpc("any_peer", "call_local")
func _spawn_replicated_node(node_path: String, authority_id: int, node_name: String, node_id: int) -> void:
	var node: Node
	if node_path not in _node_templates:
		var scene: PackedScene = load(node_path)
		_node_templates
	else:
		node = _node_templates[node_path].instantiate()
	
	add_child(node)
	node.set_owner(self)
	node.set_multiplayer_authority(authority_id)
	node.name = node_name
	
	if authority_id not in _replicated_nodes:
		_replicated_nodes[authority_id] = {}
		
	_replicated_nodes[authority_id][node_id] = node


func _replicate_nodes_to_new_player(player_id: int) -> void:
	var peer_node_dict: Array[Array] = []  # [[id, ResourcePath, name]]
	var cur_node: Node
	var node_resource_path: String
	for id in _replicated_nodes:
		if id == multiplayer.get_unique_id():
			continue
		
		for node_id in _replicated_nodes[id]:
			cur_node = _replicated_nodes[id][node_id]
			node_resource_path = _get_res_path_of_node(cur_node)
			#peer_node_dict.append([node_id, cur_node])
		
func _get_res_path_of_node(node: Node) -> String:
	var res_path: String
	#if node is Player:
		#pass
	for path in _node_templates:
		pass
		
	return res_path
	
