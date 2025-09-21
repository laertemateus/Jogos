extends Area2D
class_name Carta

enum Nype {
	PAUS,
	ESPADAS,
	COPAS,
	OUROS,
	CORINGA,
}

const NypeNome = {
	Nype.PAUS:"clubs",
	Nype.ESPADAS:"spades",
	Nype.COPAS:"hearts",
	Nype.OUROS:"diamonds",
}

signal escolher_carta(carta:Carta)

@export var nype : Nype
@export var valor : int
@export var jogo : Jogo

func _ready() -> void:
	# Carrega a imagem baseado nos valores de nype e valor
	if nype == Nype.CORINGA:
		$Frente.texture = load("res://imagens/cartas/red_joker.png")
	else:
		var str_val
		var sufixo
		
		match valor:
			1:str_val = "ace"
			11: str_val = "jack"
			12: str_val = "queen"
			13: str_val = "king"
			_: str_val = str(valor)
			
		if valor > 10: sufixo = "2"
		else: sufixo = ""
		$Frente.texture = load("res://imagens/cartas/%s_of_%s%s.png"%[str_val,NypeNome[nype],sufixo])
	

### Executa a animação de mover a carta até a posição desejada
func mover_para(destino : Vector2):
	var tween = create_tween()
	tween.tween_property(self,"position", destino, .3)
	return tween.finished
	
### Executa a animação de virar a carta para cima ou para baixo
func virar():
	var original_scale  = scale
	var tween = create_tween()
	
	tween.tween_property(self, "scale:x", 0, .3)
	tween.tween_callback(Callable(self, "_trocar_sprites"))
	tween.tween_property(self, "scale:x", original_scale.x, .3)
	
	return tween.finished
	
func escurecer():
	var tween = create_tween()
	tween.tween_property($Frente, "modulate", Color(.2,.2,.2,1), .5)
	
func _trocar_sprites():
	$Frente.visible = not $Frente.visible
	$Fundo.visible = not $Fundo.visible

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event is InputEventMouseButton and _event.is_pressed() and _event.button_index == MOUSE_BUTTON_LEFT and jogo.estado == Jogo.EstadoJogo.ESCOLHENDO:
		emit_signal("escolher_carta",self)
		
func igual(carta : Carta):
	return self.valor == carta.valor and self.nype == carta.nype
