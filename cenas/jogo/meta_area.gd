extends Area3D


# ============================================================
# REFERÊNCIA À PLAYERUI
# ============================================================

var player_ui = null


# ============================================================
# CONFIGURAÇÃO DA META
# ============================================================

@export var valor_meta: int = 200


# ============================================================
# CONFIGURAÇÃO DA FASE
# ============================================================

@export var total_fases: int = 1


# ============================================================
# VALOR ATUAL
# ============================================================

var valor_atual: int = 0


# ============================================================
# CONTROLE DA META
# ============================================================

var meta_atingida: bool = false


# ============================================================
# ITENS DENTRO DA ÁREA
# ============================================================

var itens_na_area: Array[Node3D] = []


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	print("=== META AREA INICIADA ===")

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		print("ERRO: Player não encontrado no grupo 'player'.")

		return

	print("Player encontrado: ", player.name)

	player_ui = player.get_node_or_null("PlayerUI")

	if player_ui == null:

		print("ERRO: PlayerUI não encontrada dentro do Player.")

		return

	print("PlayerUI encontrada: ", player_ui.name)

	recalcular_valor()


# ============================================================
# ITEM ENTROU
# ============================================================

func _on_body_entered(body):

	if body.is_in_group("itens_pegar"):

		if not itens_na_area.has(body):

			itens_na_area.append(body)

			print("Item entrou: ", body.name)

			recalcular_valor()


# ============================================================
# ITEM SAIU
# ============================================================

func _on_body_exited(body):

	if body.is_in_group("itens_pegar"):

		if itens_na_area.has(body):

			itens_na_area.erase(body)

			print("Item saiu: ", body.name)

			recalcular_valor()


# ============================================================
# CALCULAR VALOR TOTAL
# ============================================================

func recalcular_valor():

	valor_atual = 0


	# ========================================================
	# SOMAR VALORES DOS ITENS
	# ========================================================

	for item in itens_na_area:

		if item != null and item.dados != null:

			valor_atual += item.dados.valor


	# ========================================================
	# ATUALIZAR META NA PLAYERUI
	# ========================================================

	if player_ui != null:

		player_ui.atualizar_meta(valor_atual, valor_meta)


	# ========================================================
	# VERIFICAR META
	# ========================================================

	if valor_atual >= valor_meta:

		if not meta_atingida:

			meta_atingida = true

			print("================================")
			print("META ATINGIDA!")
			print("================================")

			# Atualiza a fase.
			if player_ui != null:

				player_ui.atualizar_fase(1, total_fases)

			# Espera 5 segundos antes de remover os itens.
			aguardar_e_remover_itens()

	else:

		meta_atingida = false

		if player_ui != null:

			player_ui.atualizar_fase(0, total_fases)


	# ========================================================
	# MOSTRAR NO OUTPUT
	# ========================================================

	print("Valor atual da meta: ", valor_atual, " / ", valor_meta)


# ============================================================
# ESPERAR 5 SEGUNDOS E REMOVER
# ============================================================

func aguardar_e_remover_itens():

	print("Itens serão removidos em 5 segundos...")

	await get_tree().create_timer(5.0).timeout

	remover_itens()


# ============================================================
# REMOVER ITENS DA ÁREA
# ============================================================

func remover_itens():

	print("Removendo itens da área...")


	# Fazemos uma cópia da lista.
	var itens_para_remover = itens_na_area.duplicate()


	# Limpamos a lista imediatamente.
	itens_na_area.clear()


	# Zeramos o valor.
	valor_atual = 0


	# Removemos cada item.
	for item in itens_para_remover:

		if item != null:

			print("Removendo: ", item.name)

			item.queue_free()


	# ========================================================
	# ATUALIZAR A META
	# ========================================================

	if player_ui != null:

		player_ui.atualizar_meta(0, valor_meta)


	print("Itens removidos. Área pronta para a próxima meta.")
