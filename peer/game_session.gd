extends PanelContainer
class_name GameSession

signal JoinRequest(String)
signal LeaveRequest(String)

var color_inactive: Color = Color.DARK_SLATE_GRAY
var color_active: Color = Color.WEB_GREEN
var _session_name: String
var activeSession: bool = false
	

func _ready():
	set_inactive()


func set_session_name(session_name: String) -> void:
	name = session_name
	%LabelSessionName.text = session_name
	_session_name = session_name


func set_active() -> void:
	activeSession = true
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = false
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_active


func set_inactive() -> void:
	activeSession = false
	%ButtonJoin.disabled = false
	%ButtonLeave.disabled = true
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_inactive
	
	
func disable_ui() -> void:
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = true
	

func enabled_ui() -> void:
	%ButtonJoin.disabled = false


func set_map_name(map_name: String) -> void:
	%LabelMap.text = map_name


func set_num_players(num: int) -> void:
	%LabelNumPlayers.text = str(num)


@rpc
func receive_session_update(_session_dict: Dictionary) -> void:
	set_num_players(_session_dict["num_players"])
	set_map_name(_session_dict["map_name"])


func _on_button_join_pressed():
	JoinRequest.emit(_session_name)


func _on_button_leave_pressed():
	LeaveRequest.emit(_session_name)
