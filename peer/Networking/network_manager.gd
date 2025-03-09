extends Node

@warning_ignore("unused_signal")
signal connected_peers_updated
@warning_ignore("unused_signal")
signal peer_disconnected_from_active_session(int)

var _session_node_replicator: SessionNodeReplicator
var _game_session: GameSession
@onready var _logger: Logging.Logger = Logging.get_logger("NodeReplicator")


func spawn_node(node_path: String, node_name: String, pos: Vector3) -> Node3D:
	assert(is_instance_valid(_session_node_replicator))
	return _session_node_replicator.spawn_node(node_path, node_name, pos)


func remove_node(node: Node3D) -> void:
	if is_instance_valid(_session_node_replicator):
		_session_node_replicator.remove_node(node)
	else:
		_logger.warning("Called to remove node %s, but replicator is not yet set anymore" % node.name)


func get_connected_peers() -> Array[int]:
	assert(is_instance_valid(_game_session))
	return _game_session.get_connected_peers()


func is_in_valid_session() -> bool:
	return is_instance_valid(_game_session)


func get_session_time() -> float:
	assert(is_instance_valid(_game_session))
	return _game_session.get_session_time()
	

#func get_replicated_nodes_of_player(player_id: int) -> Dictionary:
	#return _session_node_replicator.get_replicated_nodes_of_player(player_id)


func set_game_session(session: GameSession, replicator: SessionNodeReplicator) -> void:
	_game_session = session
	_session_node_replicator = replicator
	_session_node_replicator.start()
	
	
func invalidate_game_session() -> void:
	if is_instance_valid(_session_node_replicator):
		_session_node_replicator.stop()
	
	_session_node_replicator = null
	_game_session = null
