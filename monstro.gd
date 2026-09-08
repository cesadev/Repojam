extends CharacterBody3D

@export var velocidade := 3.0

var jogador: Node3D


func _ready():
	jogador = get_tree().get_first_node_in_group("jogador")


func _physics_process(delta):
	if jogador == null:
		return

	var direcao = jogador.global_position - global_position

	direcao.y = 0

	if direcao.length() > 1.5:
		direcao = direcao.normalized()

		velocity.x = direcao.x * velocidade
		velocity.z = direcao.z * velocidade

		move_and_slide()
	else:
		velocity.x = 0
		velocity.z = 0
