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
var _session_time: float = 0.0

@onready var _node_replicator: NodeReplicator = $SessionNodeReplicator


func _ready():
	set_inactive()
	

func _process(delta: float) -> void:
	_session_time += delta


func get_session_name() -> String:
	return _session_name


func set_active() -> void:
	activeSession = true
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = false
	
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_active
	_load_map()
	_spawn_local_player()


func set_inactive() -> void:
	activeSession = false
	%ButtonJoin.disabled = false
	%ButtonLeave.disabled = true
	var style: StyleBoxFlat = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = color_inactive
	if is_instance_valid(_current_map):
		_unload_map()
	
	
func disable_ui() -> void:
	%ButtonJoin.disabled = true
	%ButtonLeave.disabled = true
	

func enable_ui() -> void:
	%ButtonJoin.disabled = false


func _load_map() -> void:
	_current_map = load(_mapPath).instantiate()
	add_child(_current_map)
	_current_map.set_owner(self)
	
	
func _spawn_local_player() -> void:
	var scene: String = "res://addons/srcoder_thirdperson_controller/player.tscn"
	var id: int = multiplayer.get_unique_id()
	var pos: Vector3 = _current_map.get_free_spawn_location()
	var player: Player = _node_replicator.spawn_node(scene, id, "Player %s" % id, pos) as Player
	player.activate()
	
	
func _unload_map() -> void:
	_current_map.queue_free()
	_current_map = null


func _on_button_join_pressed():
	JoinRequest.emit(_session_name)


func _on_button_leave_pressed():
	LeaveRequest.emit(_session_name)


func _on_multiplayer_synchronizer_synchronized():
	%LabelSessionName.text = _session_name
	%LabelMap.text = _map_name
	%LabelNumPlayers.text = str(len(_connected_peers))
	_node_replicator.update_connected_peers(_connected_peers)
