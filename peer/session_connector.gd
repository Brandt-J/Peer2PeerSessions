extends Control

var IP_ADDRESS: String = "127.0.0.1"
var PORT: int = 31415
var sessionScene: PackedScene = preload("res://GameSession.tscn")
var sessions: Dictionary[String, GameSession] = {}


func _ready() -> void:
	# Connect signals
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.peer_disconnected.connect(_client_disconnected_from_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	%TimerConnect.start()
	

func _try_connecting_to_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(IP_ADDRESS, PORT)
	if not error:
		multiplayer.multiplayer_peer = peer
	else:
		print("Could not create peer to ip %s on port %s. Error: %s" % [IP_ADDRESS, PORT, error])


@rpc
func receive_sessions_update(sessionDict: Dictionary[String, Array]) -> void:
	# sessionsDict -> key: Name, val: [mapName, numPlayers]
	_remove_unused_sessions(sessionDict.keys())
	
	var newSession: GameSession
	var joinFunc: Callable
	
	for session_name in sessionDict:
		if session_name in sessions.keys():
			continue
			
		newSession = sessionScene.instantiate()
		%HBoxSessions.add_child(newSession)
		newSession.set_owner(%HBoxSessions)
		
		newSession.set_session_name(session_name)
		newSession.set_map_name(sessionDict[session_name][0])
		newSession.set_num_players(sessionDict[session_name][1])
		
		sessions[session_name] = newSession
		
		newSession.JoinRequest.connect(_request_join_session)
		newSession.LeaveRequest.connect(_request_leaving_session)


func _remove_unused_sessions(available_session_names: Array[String]) -> void:
	for session_name in sessions.keys():
		if session_name not in available_session_names:
			sessions[session_name].queue_free()
			sessions.erase(session_name)


func _request_session() -> void:
	rpc("create_session", %LineEditSessionName.text, %MapSelector.text)
	

func _request_join_session(active_session_name: String) -> void:
	rpc("join_session", active_session_name, multiplayer.get_unique_id())
	for session_name in sessions:
		if session_name == active_session_name:
			sessions[session_name].set_active()
		else:
			sessions[session_name].disable_ui()
	

func _request_leaving_session(active_session_name: String) -> void:
	rpc("leave_session", active_session_name, multiplayer.get_unique_id())
	for session_name in sessions:
		if session_name == active_session_name:
			sessions[session_name].set_inactive()
		sessions[session_name].enabled_ui()
	

@rpc("any_peer")
func create_session(_session_name: String, _map_name: String) -> void:
	pass


@rpc("any_peer")
func join_session(_session_name: String, _id: int) -> void:
	pass


@rpc("any_peer")
func leave_session(_session_name: String, _id: int) -> void:
	pass


func _connected_to_server() -> void:
	%LabelStatus.text = "Server Status: Successfully connected to Server"
	print(%LabelStatus.text)
	%ButtonCreateSession.disabled = false
	%TimerConnect.stop()


func _connection_failed() -> void:
	%LabelStatus.text = "Server Status: Could not connect to server"
	print(%LabelStatus.text)
	


func _client_disconnected_from_server(id: int) -> void:
	print("Client %s disconnected from server" % id)


func _server_disconnected() -> void:
	%LabelStatus.text = "Server Status: Connection to server lost"
	%ButtonCreateSession.disabled = true
	print(%LabelStatus.text)
	%TimerConnect.start()
	
