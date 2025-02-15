extends Control

var IP_ADDRESS: String = "127.0.0.1"
var PORT: int = 31415
var sessions: Dictionary[String, GameSession] = {}
var active_session: GameSession = null

var _initial_join: bool = false


func _ready() -> void:
	# Connect signals
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.peer_disconnected.connect(_client_disconnected_from_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	%TimerConnect.start()
	await get_tree().create_timer(3).timeout
	print("Requesting to join ", "Master Session")
	_request_join_session("Master Session")
	

func _try_connecting_to_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(IP_ADDRESS, PORT)
	if not error:
		multiplayer.multiplayer_peer = peer
	else:
		print("Could not create peer to ip %s on port %s. Error: %s" % [IP_ADDRESS, PORT, error])


func _request_session() -> void:
	rpc("create_session", %LineEditSessionName.text, %MapSelector.text)
	

func _request_join_session(active_session_name: String) -> void:
	rpc("join_session", active_session_name, multiplayer.get_unique_id())


@rpc
func client_join_session(active_session_name: String) -> void:
	if active_session != null:
		active_session.set_inactive()
		
	active_session = null
	for session_name in sessions:
		if session_name == active_session_name:
			sessions[session_name].set_active()
			active_session = sessions[session_name]
		else:
			sessions[session_name].disable_ui()
	hide_ui()
	

func _request_leaving_session(active_session_name: String) -> void:
	rpc("leave_session_on_server", active_session_name, multiplayer.get_unique_id())
	

@rpc("any_peer")
func create_session(_session_name: String, _map_name: String) -> void:
	pass


@rpc("any_peer")
func join_session(_session_name: String, _id: int) -> void:
	pass


@rpc("any_peer")
func leave_session_on_server(_session_name: String, _id: int) -> void:
	pass
	

@rpc
func leave_session_on_client(active_session_name: String) -> void:
	for session_name in sessions:
		if session_name == active_session_name:
			sessions[session_name].set_inactive()
		sessions[session_name].enable_ui()
	
	active_session = null
	show_ui()


func _connected_to_server() -> void:
	%LabelStatus.text = "Server Status: Successfully connected to Server. ID = %s" % multiplayer.get_unique_id()
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
	%TimerConnect.start()


func _on_session_spawner_spawned(node: Node) -> void:
	var new_session: GameSession = node as GameSession
	new_session.JoinRequest.connect(_request_join_session)
	new_session.LeaveRequest.connect(_request_leaving_session)
	sessions[new_session.get_session_name()] = new_session
	_update_no_sessions_label_visibility()


func _on_session_spawner_despawned(node: Node) -> void:
	var closed_session: GameSession = node as GameSession
	sessions.erase(closed_session.get_session_name())
	_update_no_sessions_label_visibility()
	

func _update_no_sessions_label_visibility() -> void:
	%LabelNoSessions.visible = sessions.size() == 0


func show_ui() -> void:
	for ui in _get_browser_ui_elements():
		ui.show()
	
	
func hide_ui() -> void:
	for ui in _get_browser_ui_elements():
		ui.hide()


func _get_browser_ui_elements() -> Array[Control]:
	return [%LabelAvailableSessions, %Label_Create_New_Session, %HBoxCreateSession]
