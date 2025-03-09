extends Node
class_name SessionNodeReplicator


@export var session: GameSession
var _active: bool = false
var _replicated_nodes: Dictionary[int, Dictionary] = {}  # {playerID, Dict: {nodeID: Node}
var _connected_peers: Array[int] = []
var _new_node_id: int = 0
var _node_templates: Dictionary[String, PackedScene] = {}
var _spawnable_scenes: Array[String] = [
	"res://Characters/Player.tscn",
	"res://Characters/NPC.tscn"]
@onready var _logger: Logging.Logger = Logging.get_logger("SessionNodeReplicator")


func _ready() -> void:
	_replicated_nodes[multiplayer.get_unique_id()] = {}
	NetworkManager.connected_peers_updated.connect(_update_connected_peers)
	NetworkManager.peer_disconnected_from_active_session.connect(_remove_connected_peer)


func start() -> void:
	_active = true
	var peers: Array[int] = NetworkManager.get_connected_peers()
	if peers.size() == 0:
		_logger.info("Starting without connected peers")
	else:
		_logger.info("Starting with peers %s" % peers)


func stop() -> void:
	_active = false
	_reset_replicated_nodes()
	

func _update_connected_peers() -> void:
	var updated_connected_peers: Array[int] = NetworkManager.get_connected_peers()
	# Remove old peers
	for old_id in _connected_peers:
		if old_id not in updated_connected_peers:
			_remove_connected_peer(old_id)
	
	if _active:
		# Add new peers
		for new_id in updated_connected_peers:
			if new_id not in _connected_peers and new_id != multiplayer.get_unique_id():
				_replicate_nodes_to_new_player(new_id)
			if new_id not in _replicated_nodes:
				_replicated_nodes[new_id] = {}
	
	_connected_peers = updated_connected_peers
	
	
func _remove_connected_peer(id: int) -> void:
	await get_tree().create_timer(0.1).timeout
	if id in _replicated_nodes:
		for node in _replicated_nodes[id].values():
			node.queue_free()
			_replicated_nodes.erase(id)


func spawn_node(node_path: String, node_name: String, pos: Vector3) -> Node3D:
	var node_path_id: int = _spawnable_scenes.find(node_path)
	assert(node_path_id > -1)
	assert(_active)
	
	var authority_id: int = multiplayer.get_unique_id()
	_spawn_replicated_node(node_path_id, authority_id, node_name, _new_node_id, pos)
	for id in _connected_peers:
		if id != multiplayer.get_unique_id():
			rpc_id(id, "_spawn_replicated_node", node_path_id, authority_id, node_name, _new_node_id, pos)
	var spawned_node: Node3D = _replicated_nodes[authority_id][_new_node_id]
	_new_node_id += 1
	return spawned_node


func remove_node(node: Node3D) -> void:
	var auth_id: int = multiplayer.get_unique_id()
	for node_id in _replicated_nodes[auth_id]:
		if _replicated_nodes[auth_id][node_id] == node:
			for peer_id in _connected_peers:
				rpc_id(peer_id, "_remove_replicated_node", auth_id, node_id)
			break


@rpc("any_peer", "call_local")
func _spawn_replicated_node(node_path_id: int, authority_id: int, node_name: String, node_id: int, pos: Vector3) -> void:
	if not _active:
		return
		
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


@rpc("any_peer", "call_local")
func _remove_replicated_node(authority_id: int, node_id: int) -> void:
	if authority_id in _replicated_nodes:
		var node: Node3D = _replicated_nodes[authority_id][node_id]
		node.queue_free()
		_replicated_nodes[authority_id].erase(node_id)


func _replicate_nodes_to_new_player(player_id: int) -> void:
	var node_list: Array[Array] = []  # [[id, scene_path_id, name, pos]]
	var cur_node: Node3D
	var node_resource_id: int
	var own_nodes_dict = _replicated_nodes[multiplayer.get_unique_id()]
	
	for node_id in own_nodes_dict:
		cur_node = own_nodes_dict[node_id]
		node_resource_id = _spawnable_scenes.find(cur_node.scene_file_path)
		assert(node_resource_id > -1)
		node_list.append([node_id, node_resource_id, cur_node.name, cur_node.global_position])
	_logger.info("Replicating nodes to %s" % player_id)
	rpc_id(player_id, "_receive_nodes_from_peer", multiplayer.get_unique_id(), node_list)
	

@rpc("any_peer")
func _receive_nodes_from_peer(peer_id: int, nodes_list: Array[Array]) -> void:
	if not _active:
		return
		
	_logger.info("Receiving nodes from %s" % peer_id)
	if peer_id not in _replicated_nodes:
		_replicated_nodes[peer_id] = {}

	for node_info in nodes_list:  # [id, scene_path_id, name, pos]
		_spawn_replicated_node(node_info[1], peer_id, node_info[2], node_info[0], node_info[3])


func _reset_replicated_nodes() -> void:
	for id in _replicated_nodes:
		for node in _replicated_nodes[id].values():
			node.queue_free()
	
	_replicated_nodes = {}
