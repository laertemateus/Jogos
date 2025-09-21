extends Node2D
class_name Principal


func _on_botao_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/Jogo.tscn")
