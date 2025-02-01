extends PanelContainer
class_name GameSession

signal JoinRequest(String)


var _session_name: String


func set_session_name(session_name: String) -> void:
	%LabelSessionName.text = session_name
	_session_name = session_name
	

func set_num_players(num: int) -> void:
	%LabelNumPlayers.text = str(num)


func _on_button_pressed() -> void:
	JoinRequest.emit(_session_name)
