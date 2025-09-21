extends Node2D
class_name Jogo

# Possíveis estados do jogo
enum EstadoJogo {
	INICIO,
	ESCOLHENDO,
	ANALISANDO,
	FIM
}

@export var estado : EstadoJogo

var _ultima_carta : Carta

var _pontuacao : Pontuacao = Pontuacao.new()

# QUANTIDADE TOTAL DE PARES EXISTENTES NO JOGO
const TOTAL_PARES = 16

# TOTAL DE COLUNAS DE CARTAS NA EXIBIÇÃO
const COLUNAS = 8

# VALORES DE ESPAÇAMENTO EM X E Y DAS CARTAS NA TELA
const ESPACAMENTO = Vector2(120, 160)

func _ready() -> void:
	# Cria o deck de 15 cartas diferentes
	var cartas = Array()
	var sinal_animacao = Array()
	var carta_prefab = preload("res://prefabs/carta/Carta.tscn")
	
	# Estado inicial
	estado = EstadoJogo.INICIO
	
	# Adiciona coringa
	cartas.append([0, Carta.Nype.CORINGA])
	cartas.append([0, Carta.Nype.CORINGA])
	
	# Cria as demais cartas aleatoriamente
	while cartas.size() < TOTAL_PARES * 2:
		var v = randi_range(1,13)
		var n = Carta.Nype.values()[randi() % Carta.Nype.size()]
		
		if n != Carta.Nype.CORINGA and [v,n] not in cartas:
			cartas.append([v,n])
			cartas.append([v,n])
			
	# Embaralha
	cartas.shuffle()
	
	# Inicia a construção das cartas e suas movimentações
	for i in cartas.size():
		var c = carta_prefab.instantiate()
		var destino = $MarkerBase.position
		c.valor = cartas[i][0]
		c.nype = cartas[i][1]
		c.connect("escolher_carta", self._on_escolher_carta)
		c.jogo = self
		c.position = $MarkerSpawn.position
		
		# Corrige a posição destino
		destino.x += (i%COLUNAS)*ESPACAMENTO.x
		destino.y += (i / COLUNAS)*ESPACAMENTO.y
		
		# Adiciona a carta na árvore e executa a animação
		add_child(c)
		sinal_animacao.append(c.mover_para(destino))
	
	# Verifica quando todos os sinais terminarem
	for s in sinal_animacao: await s
	
	# Vira as cartas para o usuário poder memorizar
	for c in get_tree().get_nodes_in_group("cartas"): c.virar()
		
	# Disponibiliza o tempo para visualização das cartas
	await get_tree().create_timer(10).timeout
	
	# Vira todas as cartas para começar o jogo
	sinal_animacao.clear()
	for c in get_tree().get_nodes_in_group("cartas"): sinal_animacao.append(c.virar())
	for s in sinal_animacao: await s
	
	# inicia o jogo
	estado = EstadoJogo.ESCOLHENDO
	
func _physics_process(delta: float) -> void:
	var lbl = ""
	
	if Input.is_action_pressed("ui_accept") and estado == EstadoJogo.FIM:
		get_tree().change_scene_to_file("res://cenas/Principal.tscn")
	
	# Verifica se o jogo já terminou
	if _pontuacao.pares == TOTAL_PARES and estado == EstadoJogo.ESCOLHENDO:
		estado = EstadoJogo.FIM
		for c in get_tree().get_nodes_in_group("cartas"): c.escurecer()
		lbl = "!!!GAME OVER!!!\n\n"
		lbl += "PONTUAÇÃO TOTAL: %d\n\n"%_pontuacao.resultado()
		lbl += "APERTE ENTER PARA VOLTAR AO INÍCIO"
		$LabelGameOver.text = lbl
	
	# Verifica se o jogo está em execução
	if estado in [EstadoJogo.ESCOLHENDO, EstadoJogo.ANALISANDO]: _pontuacao.tempo += delta
		
	# MONTA O LABEL
	lbl = "TEMPO:\n%s\n\n"%_pontuacao.tempo_decorrido()
	lbl += "ERROS:\n%d\n\n"%_pontuacao.erros
	lbl += "PARES RESTANTES:\n%d\n\n"%(TOTAL_PARES-_pontuacao.pares)
	lbl += "COMBOS:\n%d\n\n"%_pontuacao.combos
	lbl += "SEQUÊNCIA:\n%d\n\n"%_pontuacao.sequencia
	$LabelStatus.text = lbl
		
		
func _on_escolher_carta(carta : Carta):
	carta.virar()
	
	if _ultima_carta != null:
		estado = EstadoJogo.ANALISANDO
		await get_tree().create_timer(1).timeout
		if _ultima_carta.igual(carta):
			_pontuacao.computar_acerto()
		else:
			_pontuacao.computar_erro()
			await carta.virar()
			await _ultima_carta.virar()
			
		_ultima_carta = null
		estado = EstadoJogo.ESCOLHENDO
	else:
		_ultima_carta = carta
