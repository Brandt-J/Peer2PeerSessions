extends PanelContainer
class_name GameSession

signal JoinRequest(String)
signal LeaveRequest(String)


var _session_name: String
var activeSession: bool = false


func set_session_name(session_name: String) -> void:
	name = session_name
	%LabelSessionName.text = session_name
	_session_name = session_name


func set_active() -> void:
	activeSession = true
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = false


func set_inactive() -> void:
	activeSession = false
	%ButtonJoin.disabled = false
	%ButtonLeave.disabled = true

	
func disable_ui() -> void:
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = true
	

func enabled_ui() -> void:
	%ButtonJoin.disabled = false


func set_map_name(map_name: String) -> void:
	%LabelMap.text = map_name


func set_num_players(num: int) -> void:
	%LabelNumPlayers.text = str(num)


func _on_button_pressed() -> void:
	JoinRequest.emit(_session_name)
