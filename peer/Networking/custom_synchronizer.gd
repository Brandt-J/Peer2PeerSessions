extends MultiplayerSynchronizer
class_name CustomSynchronizer


@export var replicate_parent_transforms: bool = true  ## Whether or not to replicate global transform of the parent node
@export var render_delay: float = 100.0  ## Delay (ms) to render the replicated nodes in the past, will be adjusted dynamiccaly
@export var update_interval: float = 0.10  ## Interval in seconds in which to replicate the parent transforms (if enabled)

var _worldstates: Dictionary = {}  # key: Server Time, values: Parent Node Transforms
const _MAXNUMSTATES: int = 10

var _prev_time_stamp: float
var _next_time_stamp: float
var _parent: Node3D
var _last_connected_peers: Array[int] = []
@onready var _timer: Timer = $UpdateTimer


func _ready() -> void:
	NetworkManager.connected_peers_updated.connect(_update_connected_peers)
	NetworkManager.peer_disconnected_from_active_session.connect(_on_peer_removed)
	_update_connected_peers()
	_parent = get_parent()
	if replicate_parent_transforms:
		_timer.start(update_interval)


func _physics_process(_delta: float):
	if is_multiplayer_authority() or not replicate_parent_transforms:
		return
	
	if not NetworkManager.is_in_valid_session():
		return
	
	if len(_worldstates) < 2:
		return
		
	var cur_render_time: float = NetworkManager.get_session_time() - render_delay/1000
	_get_last_and_next_time_stamps(cur_render_time)
	_interpolate_parent_transform(cur_render_time)


func _push_transform_update() -> void:
	if not is_multiplayer_authority():
		return
	
	if not NetworkManager.is_in_valid_session():
		return
		
	for id in NetworkManager.get_connected_peers():
		if id == multiplayer.get_unique_id():
			continue
		rpc_id(id, "_receive_transform_update", NetworkManager.get_session_time(), _parent.global_transform)


@rpc("any_peer")
func _receive_transform_update(time: float, transform: Transform3D) -> void:
	if _worldstates.size() >= _MAXNUMSTATES:
		_remove_oldest_state()
	_worldstates[time] = transform


func _interpolate_parent_transform(cur_render_time: float) -> void:
	var interp_factor: float = float(cur_render_time - _prev_time_stamp) / float(_next_time_stamp - _prev_time_stamp)
	interp_factor = clampf(interp_factor, 0.0, 1.0)
	
	var prev_transform: Transform3D = _worldstates[_prev_time_stamp]
	var next_transform: Transform3D = _worldstates[_next_time_stamp]
	var target_transform: Transform3D
	
	target_transform = prev_transform.interpolate_with(next_transform, interp_factor)
	if target_transform.is_finite():
			_parent.global_transform = target_transform


func _get_last_and_next_time_stamps(render_time: float) -> void:
	var time_stamps: Array = Array(_worldstates.keys())
	time_stamps.sort()
	
	_prev_time_stamp = time_stamps[0]
	_next_time_stamp = time_stamps[-1]
	for time in time_stamps:
		if time <= render_time:
			_prev_time_stamp = time
		if time >= render_time:
			_next_time_stamp = time
			break
	
	
func _remove_oldest_state() -> void:
	var time_stamps: Array = Array(_worldstates.keys())
	time_stamps.sort()
	_worldstates.erase(time_stamps[0])


func _update_connected_peers() -> void:
	for peer_id in _last_connected_peers:
		set_visibility_for(peer_id, false)
		
	for peer_id in NetworkManager.get_connected_peers():
		set_visibility_for(peer_id, true)
			
	_last_connected_peers = NetworkManager.get_connected_peers()


func _on_peer_removed(id: int) -> void:
	set_visibility_for(id, false)
