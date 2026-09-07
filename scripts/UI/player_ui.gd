extends Control

@onready var player = null

# Referências corrigidas baseadas na nova estrutura de nós do PlayerUI.tscn
@onready var stamina_label = $HBoxContainer/VBoxContainer/HBoxContainer/Stamina
@onready var stamina_limite_label = $HBoxContainer/VBoxContainer/HBoxContainer/StaminaLimite
@onready var health_label = $HBoxContainer/VBoxContainer/HBoxContainer2/Health
@onready var health_limite_label = $HBoxContainer/VBoxContainer/HBoxContainer2/HealthLimite

# Referências de Texto da UI (Meta e Fase) corrigidas para a nova estrutura
@onready var meta_label = $HBoxContainer/VBoxContainer2/Meta
@onready var fase_label = $HBoxContainer/VBoxContainer2/Fase

# Contêiner placeholder para os itens
@onready var itens_container: HBoxContainer = null

func _ready() -> void:
	await get_tree().process_frame
	# Busca o player pelo grupo
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_node_or_null("../Player")


func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	# Atualiza a vida e o limite direto das variáveis do player.gd
	health_label.text = str(int(player.vida_atual))
	health_limite_label.text = "/" + str(int(player.vida_maxima))

	# Atualiza a stamina e o limite
	stamina_label.text = str(int(player.energia_atual))
	stamina_limite_label.text = "/" + str(int(player.energia_maxima))

# ============================================================
# FUNÇÕES CHAMADAS PELA META_AREA.GD
# ============================================================

func atualizar_meta(atual: int, meta: int) -> void:
	if meta_label:
		meta_label.text = "$" + str(atual) + " / " + _formatar_milhar(meta)

func atualizar_fase(atual: int, total: int) -> void:
	if fase_label:
		fase_label.text = str(atual) + " / " + str(total)

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================

func _formatar_milhar(valor: int) -> String:
	var s = str(valor)
	var n = s.length()
	if n <= 3:
		return s
	var result = ""
	for i in range(n):
		if i > 0 and (n - i) % 3 == 0:
			result += ","
		result += s[i]
	return result
