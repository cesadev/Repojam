extends Control

@onready var player = null

# Referências dos Labels de Stamina e Vida
@onready var stamina_label = $VBoxContainer/HBoxContainer/Stamina
@onready var stamina_limite_label = $VBoxContainer/HBoxContainer/StaminaLimite
@onready var health_label = $VBoxContainer/HBoxContainer2/Health
@onready var health_limite_label = $VBoxContainer/HBoxContainer2/HealthLimite

# Referências de Texto da UI (Meta e Fase)
@onready var meta_label = $Meta
@onready var fase_label = $Fase

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

	_criar_placeholders_itens()

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

	# Nota: O dinheiro/grana atual do jogador também pode ser puxado direto do player se quiser,
	# mas mantemos a compatibilidade caso a meta_area atualize via função abaixo.

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

func _criar_placeholders_itens() -> void:
	itens_container = HBoxContainer.new()
	itens_container.name = "ItensContainer"
	itens_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	itens_container.offset_left = -200
	itens_container.offset_top = -150
	itens_container.offset_right = 200
	itens_container.offset_bottom = -100
	add_child(itens_container)

	for i in range(4):
		var placeholder = TextureRect.new()
		placeholder.custom_minimum_size = Vector2(40, 40)
		placeholder.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		
		var img = Image.create(40, 40, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.2, 0.2, 0.2, 0.6))
		placeholder.texture = ImageTexture.create_from_image(img)
		
		itens_container.add_child(placeholder)
