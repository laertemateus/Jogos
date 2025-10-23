extends Node2D

#var multiplayer : MultiplayerAPI  = get_tree().get_multiplayer()


func _ready() -> void:
	multiplayer.peer_connected.connect(Callable(self, "_jogador_conectado"))
	
	if multiplayer.is_server():
		_jogador_conectado(1)
		

func _spawn_jogador(data):
	var jogador = preload("res://prefabs/jogador/jogador.tscn").instantiate()
	jogador.set_multiplayer_authority(data)
	return jogador

func _jogador_conectado(peer_id):
	$MultiplayerSpawner.spawn_function = Callable(self,"_spawn_jogador")
	$MultiplayerSpawner.spawn(peer_id)
