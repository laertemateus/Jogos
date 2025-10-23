extends CharacterBody2D

var camera : Camera2D

func _physics_process(_delta: float) -> void:
	$LabelID.text = str(get_multiplayer_authority())
	$LabelPosition.text = str(global_position)
	if not is_multiplayer_authority():
		return
	
	# Adiciona a camera 2D ao jogador que é controlado
	if camera == null:
		camera = Camera2D.new()
		add_child(camera)
		
	velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 500
	move_and_slide()
