extends CharacterBody2D
class_name Player

# =====================
# CONFIGURAÇÕES BÁSICAS
# =====================

@export var speed: float = 300.0
@export var acceleration: float = 800.0
@export var jump_velocity: float = -450.0
@export var gravity: Vector2 = Vector2(0, 600)

var input_direction: Vector2 = Vector2.ZERO
var jump_buffer: bool = true
var double_jump: bool = true

@onready var sprite: Sprite2D = $Sprite2D

# =====================
# LOOP PRINCIPAL
# =====================

func _physics_process(delta: float) -> void:
	# Atualiza direção e sprite
	input_direction = _get_input_direction()
	_set_sprite_direction()

	# Gravidade
	apply_gravity(delta)

	# Movimento horizontal com aceleração
	move_horizontal(delta)

	# Pulo e duplo pulo
	handle_jump()

	# Aplica movimento
	move_and_slide()


# =====================
# FUNÇÕES DE MOVIMENTO
# =====================

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += gravity * delta
	else:
		double_jump = true  # reseta o duplo pulo ao tocar o chão


func move_horizontal(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x,
		input_direction.x * speed,
		acceleration * delta
	)


func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump:
			velocity.y = jump_velocity
			double_jump = false


# =====================
# FUNÇÕES AUXILIARES
# =====================

func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		0
	)

func _set_sprite_direction() -> void:
	if input_direction.x != 0:
		sprite.flip_h = input_direction.x < 0
