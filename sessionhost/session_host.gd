extends Node

var PORT: int = 31415
var MAX_CLIENTS: int = 8


func _ready():
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
