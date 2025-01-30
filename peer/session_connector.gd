extends Node

var IP_ADDRESS: String = "127.0.0.1"
var PORT: int = 31415


func _ready() -> void:
	# Create client.
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
