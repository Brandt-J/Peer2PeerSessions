extends PanelContainer
class_name GameSession

signal JoinRequest(String)
signal LeaveRequest(String)

var color_inactive: Color = Color.DARK_SLATE_GRAY
var color_active: Color = Color.WEB_GREEN
var _session_name: String
var activeSession: bool = false
var _map_name: String
var _current_map: GameMap
var _mapPath: String = "res://Maps/Map1.tscn"
var _connected_peers: Array[int] = []
var _authority_id: int = -1


func _ready():
	set_inactive()


func get_session_name() -> String:
	return _session_name


#func set_session_name(session_name: String) -> void:
	#name = session_name
	#%LabelSessionName.text = session_name
	#_session_name = session_name


func set_active(authority_id: int) -> void:
	activeSession = true
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = false
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_active
	_load_map(authority_id)


func set_inactive() -> void:
	activeSession = false
	%ButtonJoin.disabled = false
	%ButtonLeave.disabled = true
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_inactive
	if is_instance_valid(_map_name):
		_unload_map()
	
	
func disable_ui() -> void:
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = true
	

func enabled_ui() -> void:
	%ButtonJoin.disabled = false


#func set_map_name(map_name: String) -> void:
	#%LabelMap.text = map_name


#func set_num_players(num: int) -> void:
	#%LabelNumPlayers.text = str(num)


#@rpc
#func receive_session_update(_session_dict: Dictionary) -> void:
	#set_num_players(_session_dict["num_players"])
	#set_map_name(_session_dict["map_name"])


func _load_map(authority_id: int) -> void:
	_current_map = load(_mapPath).instantiate()
	add_child(_current_map)
	_current_map.set_owner(self)
	_current_map.set_authority(authority_id)
	#_map_name._spawn_player()
	
	
func _unload_map() -> void:
	_current_map.queue_free()
	_current_map = null


func _on_button_join_pressed():
	JoinRequest.emit(_session_name)


func _on_button_leave_pressed():
	LeaveRequest.emit(_session_name)


func _on_multiplayer_synchronizer_synchronized():
	%LabelSessionName.text = _session_name
	if is_instance_valid(_map_name):
		%LabelMap.text = _map_name
	%LabelNumPlayers.text = str(len(_connected_peers))
