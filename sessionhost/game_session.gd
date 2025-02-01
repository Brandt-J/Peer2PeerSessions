extends Control
class_name GameSession

var _session_name: String = "DefaultName"
var _connected_peers: Array[int] = []
var _peer_labels: Array[Label] = []

@onready var _vbox: VBoxContainer = $VBoxContainer


func set_session_name(session_name: String) -> void:
	_session_name = session_name
	%LabelSessionName.text = session_name


func add_peer(id: int) -> void:
	_connected_peers.append(id)
	

func remove_peer(id: int) -> void:
	_connected_peers.erase(id)


func get_peers() -> Array[int]:
	return _connected_peers


func get_num_players() -> int:
	return len(_connected_peers)
	

func get_session_name() -> String:
	return _session_name


func _add_label_for_id(id: int) -> void:
	var newLabel: Label = Label.new()
	newLabel.text = str(id)
	
