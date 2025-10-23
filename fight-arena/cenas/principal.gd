extends Node2D


func _on_button_host_button_down() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9966)
	get_tree().get_multiplayer().multiplayer_peer = peer
	get_tree().change_scene_to_file("res://cenas/jogo.tscn")


func _on_button_connect_button_down() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client($EditServerHost.text, 9966)
	get_tree().get_multiplayer().multiplayer_peer = peer
	get_tree().change_scene_to_file("res://cenas/jogo.tscn")
	
