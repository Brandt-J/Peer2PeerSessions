extends Node

signal connected_peers_updated(Array)

var _session_node_replicator: SessionNodeReplicator
var _game_session: GameSession


func spawn_node(node_path: String, node_name: String, pos: Vector3) -> Node3D:
	assert(is_instance_valid(_session_node_replicator))
	return _session_node_replicator.spawn_node(node_path, node_name, pos)


func get_session_time() -> float:
	assert(is_instance_valid(_game_session))
	return _game_session.get_session_time()
	

func get_replicated_nodes_of_player(player_id: int) -> Dictionary:
	return _session_node_replicator.get_replicated_nodes_of_player(player_id)


func set_game_session(session: GameSession, replicator: SessionNodeReplicator) -> void:
	_game_session = session
	_session_node_replicator = replicator
	_session_node_replicator.start()
	
	
func invalidate_game_session() -> void:
	if is_instance_valid(_session_node_replicator):
		_session_node_replicator.stop()
	
	_session_node_replicator = null
	_game_session = null
