extends MultiplayerSynchronizer


var _last_connected_peers: Array[int] = []


func _ready() -> void:
	NetworkManager.connected_peers_updated.connect(_update_connected_peers)


func _update_connected_peers(connected_peers: Array[int]) -> void:
	for peer_id in _last_connected_peers:
		set_visibility_for(peer_id, false)
		
	for peer_id in connected_peers:
		set_visibility_for(peer_id, true)
	
	_last_connected_peers = connected_peers
