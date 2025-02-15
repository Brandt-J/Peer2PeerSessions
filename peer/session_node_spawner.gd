extends Node
class_name NodeReplicator


var _replicated_nodes: Dictionary[int, Dictionary] = {}  # {playerID, Dict: {nodeID: Node}
var _connected_peers: Array[int] = []
var _new_node_id: int = 0
var _node_templates: Dictionary[String, PackedScene] = {}
var _spawnable_scenes: Array[String] = ["res://addons/srcoder_thirdperson_controller/player.tscn"]


func _ready() -> void:
	_replicated_nodes[multiplayer.get_unique_id()] = {}


func update_connected_peers(connected_peers: Array[int]) -> void:
	for new_id in connected_peers:
		if new_id not in _connected_peers and new_id != multiplayer.get_unique_id():
			_replicate_nodes_to_new_player(new_id)
	
	_connected_peers = connected_peers
	for id in connected_peers:
		if id not in _replicated_nodes:
			_replicated_nodes[id] = {}


func spawn_node(node_path: String, authority_id: int, node_name: String, pos: Vector3) -> Node3D:
	var node_path_id: int = _spawnable_scenes.find(node_path)
	assert(node_path_id > -1)
	_spawn_replicated_node(node_path_id, authority_id, node_name, _new_node_id, pos)
	for id in _connected_peers:
		if id != multiplayer.get_unique_id():
			rpc_id(id, "_spawn_replicated_node", node_path_id, authority_id, node_name, _new_node_id, pos)
	var spawned_node: Node3D = _replicated_nodes[authority_id][_new_node_id]
	_new_node_id += 1
	return spawned_node


@rpc("any_peer", "call_local")
func _spawn_replicated_node(node_path_id: int, authority_id: int, node_name: String, node_id: int, pos: Vector3) -> void:
	var node: Node3D
	var node_path: String = _spawnable_scenes[node_path_id]
	if node_path not in _node_templates:
		_node_templates[node_path] = load(node_path)
	
	node = _node_templates[node_path].instantiate()
	
	add_child(node)
	node.set_owner(self)
	node.set_multiplayer_authority(authority_id)
	node.name = node_name
	node.global_position = pos
	
	if authority_id not in _replicated_nodes:
		_replicated_nodes[authority_id] = {}
		
	_replicated_nodes[authority_id][node_id] = node


func _replicate_nodes_to_new_player(player_id: int) -> void:
	var node_list: Array[Array] = []  # [[id, scene_path_id, name, pos]]
	var cur_node: Node3D
	var node_resource_id: int
	var own_nodes_dict = _replicated_nodes[multiplayer.get_unique_id()]
	#for id in _replicated_nodes:
		#if id == multiplayer.get_unique_id():
			#continue
	
	for node_id in own_nodes_dict:
		cur_node = own_nodes_dict[node_id]
		node_resource_id = _spawnable_scenes.find(cur_node.scene_file_path)
		assert(node_resource_id > -1)
		node_list.append([node_id, node_resource_id, cur_node.name, cur_node.global_position])
	rpc_id(player_id, "_receive_nodes_from_peer", multiplayer.get_unique_id(), node_list)
	

@rpc("any_peer")
func _receive_nodes_from_peer(peer_id: int, nodes_list: Array[Array]) -> void:
	print("Receiving nodes from ", peer_id)
	if peer_id not in _replicated_nodes:
		_replicated_nodes[peer_id] = {}

	for node_info in nodes_list:  # [id, scene_path_id, name, pos]
		#_spawn_replicated_node(node_path_id: int, authority_id: int, node_name: String, node_id: int, pos: Vector3) -> void:
		_spawn_replicated_node(node_info[1], peer_id, node_info[2], node_info[0], node_info[3])
