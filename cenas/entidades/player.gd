extends CharacterBody3D

@export var speed = 4.0
@export var fall_acceleration = 75.0
@export var mouse_sensitivity = 0.003

var target_velocity = Vector3.ZERO

@onready var pivot = $Pivot
@onready var camera = $Pivot/Camera3D

var camera_rotation_x = 0.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	# Movimento do mouse
	if event is InputEventMouseMotion:
		# Girar para esquerda/direita
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Girar para cima/baixo
		camera_rotation_x -= event.relative.y * mouse_sensitivity

		# Limitar a rotação vertical
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.5)

		pivot.rotation.x = camera_rotation_x

	# ESC libera o mouse
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta):
	var direction = Vector3.ZERO

	# Direção da câmera
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	# Não permitir que olhar para cima/baixo altere o movimento
	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	# Movimento
	if Input.is_action_pressed("move_forward"):
		direction += forward

	if Input.is_action_pressed("move_back"):
		direction -= forward

	if Input.is_action_pressed("move_right"):
		direction += right

	if Input.is_action_pressed("move_left"):
		direction -= right

	# Evita andar mais rápido na diagonal
	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Velocidade horizontal
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Gravidade
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0

	# Movimento do personagem
	velocity = target_velocity
	move_and_slide()
