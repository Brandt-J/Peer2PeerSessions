extends Control

var PORT: int = 31415
var MAX_CLIENTS: int = 8

var sessions: Array[GameSession] = []
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
func create_session(session_name: String) -> void:
	if len(sessions) == 0:
		%LabelNoSessions.queue_free()
		
	var newSession: GameSession = sessionScene.instantiate()
	sessions.append(newSession)
	
	%HBoxSessions.add_child(newSession)
	newSession.set_owner(%HBoxSessions)
	newSession.set_session_name(session_name)
	
	_send_session_update_to_peers_in_lobby()


func _send_session_update_to_peers_in_lobby() -> void:
	var sessionDict: Dictionary[String, int] = {}  # key: Name, val: numPlayers
	for session in sessions:
		sessionDict[session.get_session_name()] = session.get_num_players()
		
	for id in _get_peers_in_lobby():
		rpc_id(id, "receive_session_update", sessionDict)


func _send_session_update_to_peer(id: int) -> void:
	var sessionDict: Dictionary[String, int] = {}  # key: Name, val: numPlayers
	for session in sessions:
		sessionDict[session.get_session_name()] = session.get_num_players()
		
	rpc_id(id, "receive_session_update", sessionDict)
		

func _peer_connected(id: int) -> void:
	print("peer %s connected" % id)
	connected_peers.append(id)
	_update_peer_labels()
	_send_session_update_to_peer(id)
	

func _peer_disconnected(id: int) -> void:
	print("peer %s disconnected" % id)
	connected_peers.erase(id)
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
	for session in sessions:
		peers_in_session += session.get_peers()
	
	for id in connected_peers:
		if id not in peers_in_session:
			peers_in_lobby.append(id)
	
	return peers_in_lobby
	

@rpc
func receive_session_update(_sessionDict: Dictionary[String, int]) -> void:
	pass
