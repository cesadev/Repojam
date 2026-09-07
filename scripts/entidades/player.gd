extends CharacterBody3D

# ============================================================
# VARIÁVEIS DE STATUS E INVENTÁRIO
# ============================================================
@export var vida_maxima: int = 100
var vida_atual: int = vida_maxima

@export var energia_maxima: float = 40.0
var energia_atual: float = energia_maxima

@export var dinheiro_maximo: int = 9000
var dinheiro_atual: int = 0

var estado: String = "idle"
var inventario: Array = []

# Variável de controle atualizada pelo script de interação de itens
var segurando_item: bool = false

# ============================================================
# CONFIGURAÇÕES DE MOVIMENTO
# ============================================================
@export var walk_speed = 4.0
@export var run_speed = 8.0
@export var crouch_speed = 2.0
@export var fall_acceleration = 75.0

@export var jump_force = 15.0
@export var compact_dash_force = 30.0 
@export var slide_boost = 14.0 

# ============================================================
# CONFIGURAÇÕES DE CÂMERA E EFEITOS
# ============================================================
@export var mouse_sensitivity = 0.003
@export var default_camera_y = 0.55
@export var crouch_camera_y = 0.2
@export var compact_camera_y = 0.0

@export var fov_normal = 75.0
@export var fov_queda = 95.0 

var target_velocity = Vector3.ZERO
var current_speed = 0.0
var compact_timer = 0.0

var is_flipping = false 
var shake_intensity = 0.0

@onready var pivot = $Pivot
@onready var camera = $Pivot/Camera3D
@onready var lanterna_light = $Pivot/Camera3D/lanterna/SpotLight3D

var camera_rotation_x = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_rotation_x -= event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.5)
		pivot.rotation.x = camera_rotation_x

	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# ============================================================
	# GESTÃO DA CÂMERA
	# ============================================================
	var target_camera_y = default_camera_y
	var target_fov = fov_normal
	
	if estado in ["crouch", "crouch_slide"]:
		target_camera_y = crouch_camera_y
	elif estado == "compacto_ar":
		target_camera_y = compact_camera_y
		target_fov = fov_queda 
	elif estado == "compacto_chao":
		target_camera_y = compact_camera_y
		
	camera.position.y = lerp(camera.position.y, target_camera_y, 12.0 * delta)
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	if is_flipping:
		camera.rotation.x -= 6.0 * delta 
	else:
		camera.rotation.x = lerp_angle(camera.rotation.x, 0.0, 12.0 * delta)
		
	if shake_intensity > 0:
		shake_intensity = lerp(shake_intensity, 0.0, 10.0 * delta)
		camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		camera.v_offset = randf_range(-shake_intensity, shake_intensity)
	else:
		camera.h_offset = 0.0
		camera.v_offset = 0.0

	# ============================================================
	# GESTÃO DE TIMERS
	# ============================================================
	if compact_timer > 0:
		compact_timer -= delta
		if compact_timer <= 0 and is_on_floor():
			estado = "idle"

	# ============================================================
	# DIREÇÃO
	# ============================================================
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	# ============================================================
	# MÁQUINA DE ESTADOS E MOVIMENTO
	# ============================================================
	if is_on_floor():
		if estado == "compacto_ar":
			estado = "compacto_chao"
			compact_timer = 1.5 
			is_flipping = false 
			shake_intensity = 0.3 
			
		if compact_timer > 0:
			current_speed = lerp(current_speed, 0.0, 8.0 * delta)
			target_velocity.x = forward.x * current_speed
			target_velocity.z = forward.z * current_speed
			
		else:
			var direction = Vector3.ZERO
			if Input.is_action_pressed("move_forward"): direction += forward
			if Input.is_action_pressed("move_back"): direction -= forward
			if Input.is_action_pressed("move_right"): direction += right
			if Input.is_action_pressed("move_left"): direction -= right
			
			if direction != Vector3.ZERO:
				direction = direction.normalized()
				
			var is_moving = direction != Vector3.ZERO
			var is_running = Input.is_action_pressed("sprint") and is_moving and energia_atual > 0
			var is_crouching = Input.is_action_pressed("crouch")
			var just_crouched = Input.is_action_just_pressed("crouch")

			# Gasta 25 de energia e ativa o compacto no chão
			if Input.is_action_just_pressed("compact") and energia_atual >= 25.0:
				energia_atual -= 25.0 
				estado = "compacto_chao"
				compact_timer = 1.5 
				shake_intensity = 0.1 
				
			else:
				var target_speed = 0.0
				
				if is_crouching:
					if estado == "run" or estado == "crouch_slide":
						if just_crouched and estado == "run":
							current_speed = slide_boost
							
						estado = "crouch_slide"
						target_speed = crouch_speed
						if current_speed <= crouch_speed + 0.5:
							estado = "crouch"
					else:
						estado = "crouch"
						target_speed = crouch_speed
						
				elif is_running:
					estado = "run"
					target_speed = run_speed
					energia_atual -= 15.0 * delta # Gasta energia ao correr
					
				elif is_moving:
					estado = "walk"
					target_speed = walk_speed
					
				else:
					estado = "idle"

				# Recupera energia se não estiver correndo
				if estado != "run":
					energia_atual += 8.0 * delta

				energia_atual = clamp(energia_atual, 0.0, energia_maxima)

				if estado == "crouch_slide":
					current_speed = lerp(current_speed, target_speed, 2.0 * delta) 
				else:
					current_speed = lerp(current_speed, target_speed, 10.0 * delta) 

				target_velocity.x = direction.x * current_speed
				target_velocity.z = direction.z * current_speed

				if Input.is_action_just_pressed("ui_accept"): 
					estado = "jump"
					target_velocity.y = jump_force

	else:
		energia_atual += 4.0 * delta
		energia_atual = clamp(energia_atual, 0.0, energia_maxima)

		if estado == "compacto_ar":
			target_velocity.y -= (fall_acceleration * 0.6) * delta
		else:
			target_velocity.y -= fall_acceleration * delta
		
		# Gasta 25 de energia e ativa o compacto no ar
		if Input.is_action_just_pressed("compact") and estado != "compacto_ar" and energia_atual >= 25.0:
			energia_atual -= 25.0 
			estado = "compacto_ar"
			
			if current_speed > walk_speed + 0.5:
				target_velocity.x = forward.x * compact_dash_force
				target_velocity.z = forward.z * compact_dash_force
				target_velocity.y = 6.0 
				is_flipping = true
			else:
				target_velocity.y = -5.0
				target_velocity.x = 0
				target_velocity.z = 0
				
		elif estado != "compacto_ar":
			estado = "jump"

	velocity = target_velocity
	move_and_slide()

	# ============================================================
	# GESTÃO DA LANTERNA
	# ============================================================
	if lanterna_light:
		var esta_compacto = estado in ["compacto_ar", "compacto_chao"]
		
		# A lanterna acende apenas se NÃO estiver compacto E NÃO estiver segurando item
		if not esta_compacto and not segurando_item:
			lanterna_light.visible = true
		else:
			lanterna_light.visible = false
