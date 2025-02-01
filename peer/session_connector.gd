extends Control

var IP_ADDRESS: String = "127.0.0.1"
var PORT: int = 31415
var sessionScene: PackedScene = preload("res://GameSession.tscn")


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
func receive_session_update(sessionDict: Dictionary[String, int]) -> void:
	for child in %HBoxSessions.get_children():
		child.queue_free()
	
	var newSession: GameSession
	for session_name in sessionDict:
		newSession = sessionScene.instantiate()
		%HBoxSessions.add_child(newSession)
		newSession.set_owner(%HBoxSessions)
		
		newSession.set_session_name(session_name)
		newSession.set_num_players(sessionDict[session_name])


func _request_session() -> void:
	rpc("create_session", %LineEditSessionName.text)
	
	
@rpc("any_peer")
func create_session(_session_name: String) -> void:
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
	
