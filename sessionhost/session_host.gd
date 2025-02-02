extends Control

var PORT: int = 31415
var MAX_CLIENTS: int = 8

var sessions: Dictionary[String, GameSession] = {}  # key: session_name, val: SessionObject
var sessionScene: PackedScene = preload("res://GameSession.tscn")
var connected_peers: Array[int] = []


func _ready():
	# Connect Signals:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	%LabelServerState.text = "Server Running"


@rpc("any_peer")
func create_session(session_name: String, map_name: String) -> void:
	if len(sessions) == 0:
		%LabelNoSessions.queue_free()
	
	if session_name in sessions:
		return
	
	var newSession: GameSession = sessionScene.instantiate()
	sessions[session_name] = newSession
	
	%HBoxSessions.add_child(newSession)
	newSession.set_owner(%HBoxSessions)
	newSession.set_session_name(session_name)
	newSession.set_map(map_name)
	
	_send_session_update_to_peers_in_lobby()
	

@rpc("any_peer")
func join_session(session_name: String, id: int) -> void:
	sessions[session_name].add_peer(id)
	_update_peer_labels()
	
	
@rpc("any_peer")
func leave_session(session_name: String, id: int) -> void:
	sessions[session_name].remove_peer(id)
	_update_peer_labels()


func _send_session_update_to_peers_in_lobby() -> void:
	for id in _get_peers_in_lobby():
		rpc_id(id, "receive_sessions_update", _get_sessions_dict())


func _send_session_update_to_peer(id: int) -> void:
	rpc_id(id, "receive_sessions_update", _get_sessions_dict())


func _peer_connected(id: int) -> void:
	print("peer %s connected" % id)
	connected_peers.append(id)
	_update_peer_labels()
	_send_session_update_to_peer(id)


func _peer_disconnected(id: int) -> void:
	print("peer %s disconnected" % id)
	connected_peers.erase(id)
	for session in sessions.values():
		session.remove_peer(id)
	_update_peer_labels()
	
	
func _update_peer_labels() -> void:
	for child in %HBoxPeers.get_children():
		child.queue_free()
	
	var newLbl: Label
	for id in _get_peers_in_lobby():
		newLbl = Label.new()
		newLbl.text = str(id)
		%HBoxPeers.add_child(newLbl)
		newLbl.set_owner(%HBoxPeers)
	

func _get_peers_in_lobby() -> Array[int]:
	var peers_in_lobby: Array[int] = []
	var peers_in_session: Array[int] = []
	for session in sessions.values():
		peers_in_session += session.get_peers()
	
	for id in connected_peers:
		if id not in peers_in_session:
			peers_in_lobby.append(id)
	
	return peers_in_lobby


func _get_sessions_dict() -> Dictionary[String, Array]:
	var sessionDict: Dictionary[String, Array] = {}  # key: Name, val: [mapName, numPlayers]
	for session in sessions.values():
		sessionDict[session.get_session_name()] = [session.get_map_name(), session.get_num_players()]
	
	return sessionDict


@rpc
func receive_sessions_update(_sessionDict: Dictionary[String, Array]) -> void:
	pass
