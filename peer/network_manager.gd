extends Node

signal connected_peers_updated(Array)

var _session_node_replicator: SessionNodeReplicator


func spawn_node(node_path: String, node_name: String, pos: Vector3) -> Node3D:
	assert(is_instance_valid(_session_node_replicator))
	return _session_node_replicator.spawn_node(node_path, node_name, pos)


func set_session_replicator(replicator: SessionNodeReplicator) -> void:
	_session_node_replicator = replicator
	_session_node_replicator.start()
	
	
func invalidate_session_replicator() -> void:
	if is_instance_valid(_session_node_replicator):
		_session_node_replicator.stop()
		
	_session_node_replicator = null
