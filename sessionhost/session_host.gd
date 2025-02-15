extends Control

var PORT: int = 31415
var MAX_CLIENTS: int = 8

var sessions: Dictionary[String, GameSession] = {}  # key: session_name, val: SessionObject
var session_scene: PackedScene = preload("res://GameSession.tscn")
var connected_peers: Array[int] = []

@onready var session_spawner: MultiplayerSpawner = $SessionSpawner


func _ready():
	# Connect Signals:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	%LabelServerState.text = "Server Running"
	create_session("Master Session", "TestMap")
	create_session("Krasse Session", "TestMap2")


@rpc("any_peer")
func create_session(session_name: String, map_name: String) -> void:
	if len(sessions) == 0:
		%LabelNoSessions.hide()
	
	if session_name in sessions:
		return
	
	var newSession: GameSession = session_scene.instantiate()
	%HBoxSessions.add_child(newSession)
	newSession.set_owner(%HBoxSessions)
	
	sessions[session_name] = newSession
	newSession.name = session_name
	newSession.set_session_name(session_name)
	newSession.set_map(map_name)
	
	newSession.Closed.connect(_close_session)
	

@rpc("any_peer")
func join_session(session_name: String, id: int) -> void:
	var curSession: GameSession = sessions[session_name]
	curSession.add_peer(id)
	_update_peer_labels()
	
	rpc_id(id, "client_join_session", session_name)

	
@rpc
func client_join_session(_active_session_name: String) -> void:
	pass
	
	
@rpc("any_peer")
func leave_session_on_server(session_name: String, id: int) -> void:
	sessions[session_name].remove_peer(id)
	_update_peer_labels()
	rpc_id(id, "leave_session_on_client", session_name)
	
	
@rpc
func leave_session_on_client(_active_session_name: String) -> void:
	pass


func _peer_connected(id: int) -> void:
	print("peer %s connected" % id)
	connected_peers.append(id)
	_update_peer_labels()


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


func _close_session(session_name: String) -> void:
	var active_session: GameSession = sessions[session_name]
	var players_in_session: Array[int] = active_session.get_peers().duplicate()  # duplicate, bc. we modify the original list during the loop
	for player_id in players_in_session:
		rpc_id(player_id, "leave_session_on_client", session_name)
		active_session.remove_peer(player_id)
	
	active_session.queue_free()
	sessions.erase(session_name)
	_update_peer_labels()
