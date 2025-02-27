extends Node
class_name NodeTransformInterpolation


var worldstates: Dictionary = {}  # key: player_id, val: Dict with key: Server Time, values: Dict of replicated node transforms
const MAXNUMSTATES: int = 10
@export var render_delay: float = 100.0  # delay (ms) to render the replicated nodes in the past, will be adjusted dynamiccaly

var prev_time_stamp: float
var next_time_stamp: float
var _active: bool = false


func _ready():
	NetworkManager.connected_peers_updated.connect(_update_connected_peers)


func activate() -> void:
	_active = true
	
	
func stop() -> void:
	_active = false
	worldstates = {}
	

func register_node_transform_update(player_id: int, time: float, node_dict: Dictionary[int, Transform3D]) -> void:
	if player_id not in worldstates:
		worldstates[player_id] = {time: node_dict}
	else:
		var player_states: Dictionary = worldstates[player_id]   # key: time, val: Dictionary[id: Transform3D]
		if player_states.size() >= MAXNUMSTATES:
			_remove_oldest_state(player_states)
		player_states[time] = node_dict


func _physics_process(_delta: float):
	if not _active:
		return
		
	var player_world_states: Dictionary  # key: time, val: Dictionary[id: Transform3D]
	var prev_world_state: Dictionary
	var next_world_state: Dictionary
	var cur_render_time: float = NetworkManager.get_session_time() - render_delay/1000
	var player_nodes: Dictionary = {}  # Key: NodeID, val: Node3D
	
	for player_id in worldstates.keys():
		player_world_states = worldstates[player_id]
		if len(player_world_states) < 2:
			continue
		player_world_states = player_world_states
		_get_last_and_next_time_stamps(player_world_states, cur_render_time)
		
		var interpFactor = float(cur_render_time - prev_time_stamp) / float(next_time_stamp - prev_time_stamp)
		interpFactor = clampf(interpFactor, 0.0, 1.0)
		prev_world_state = player_world_states[prev_time_stamp]  # key: int, val: Transform3D
		next_world_state = player_world_states[next_time_stamp]  # key: int, val: Transform3D
		player_nodes = NetworkManager.get_replicated_nodes_of_player(player_id)
		for id in player_nodes:
			if id in prev_world_state and id in next_world_state:
				player_nodes[id].global_transform = prev_world_state[id].interpolate_with(next_world_state[id], interpFactor)


func _update_connected_peers(connected_peers: Array[int]) -> void:
	for new_id in connected_peers:
		if new_id not in worldstates:
			worldstates[new_id] = {}
	
	for old_id in worldstates.keys():
		if old_id not in connected_peers:
			worldstates.erase(old_id)
	

func _get_last_and_next_time_stamps(world_states: Dictionary, render_time: float) -> void:
	"""
	:param: world_states: key: Time, val: Dict[node_id, Transform3D]
	"""
	var time_stamps: Array = Array(world_states.keys())
	time_stamps.sort()
	
	prev_time_stamp = time_stamps[0]
	next_time_stamp = time_stamps[-1]
	for time in time_stamps:
		if time <= render_time:
			prev_time_stamp = time
		if time >= render_time:
			next_time_stamp = time
			break
	
	
func _remove_oldest_state(player_states: Dictionary) -> void:
	"""
	:param: player_states: key: Time, val: Dict[node_id, Transform3D]
	"""
	var time_stamps: Array = Array(player_states.keys())
	time_stamps.sort()
	player_states.erase(time_stamps[0])
