extends Node
class_name Pontuacao

@export var erros : int = 0
@export var pares : int = 0 
@export var tempo : float = 0
@export var sequencia: int = 0
@export var combos : int = 0
@export var max_sequencia : int = 0

func resultado():
	var minutos = int(tempo/60)
	return pares * 100 - 10 * erros  + max(0, 3-minutos) * 100 + combos*50
	
func computar_acerto():
	pares += 1
	sequencia += 1
	
	if sequencia%3 == 0:
		combos += 1
		
func computar_erro():
	if sequencia > max_sequencia: max_sequencia = sequencia
	sequencia = 0
	erros+=1
	
func tempo_decorrido():
	return "%02d:%02d"%[ int(tempo/60), int(tempo)%60 ]
