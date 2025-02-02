extends Control
class_name GameSession

var _session_name: String = "DefaultName"
var _map_name: String = "UnknownMap"
var _connected_peers: Array[int] = []


func set_session_name(session_name: String) -> void:
	name = session_name
	_session_name = session_name
	%LabelSessionName.text = session_name
	
	
func set_map(map_name: String) -> void:
	_map_name = map_name
	%LabelMap.text = map_name
	

func get_map_name() -> String:
	return _map_name


func add_peer(id: int) -> void:
	if id not in _connected_peers:
		_connected_peers.append(id)
		_update_id_labels()
	

func remove_peer(id: int) -> void:
	_connected_peers.erase(id)
	_update_id_labels()


func get_peers() -> Array[int]:
	return _connected_peers


func get_num_players() -> int:
	return len(_connected_peers)
	

func get_session_name() -> String:
	return _session_name


func _update_id_labels() -> void:
	for child in %VBoxSessions.get_children():
		child.queue_free()
	
	var newLabel: Label
	for id in _connected_peers:
		newLabel = Label.new()
		newLabel.text = str(id)
		%VBoxSessions.add_child(newLabel)
		newLabel.set_owner(%VBoxSessions)
