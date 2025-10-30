extends CharacterBody2D

var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")

enum Estados{
	PATRULHA,
	CACADA,
	DANO,
	MORTE,
	ATAQUE
}
var vida_maxima = 40
var vida_atual = vida_maxima
var velocidade :float = 20.0
var estado_atual = Estados.PATRULHA
var velocidade_maxima_x: float = 80.0
var direcao = -1
var player :CharacterBody2D = null
@export var distancia_ataque: float = 30.0
var pode_atacar: bool = true

@onready var hurtbox: Area2D = $HurtBox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var AreaPlayer:Area2D = $Area2D
@onready var timer:Timer = $Timer
@onready var timerVira:Timer = $Timer2
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var DetectorChaoDireita: Area2D = $Area2D2
@onready var DetectorChaoEsquerda: Area2D = $Area2D3
@onready var enemy_hitbox_collision: CollisionShape2D = $EnemyHitbox/CollisionShape2D # Referência ao hitbox do inimigo

var pode_virar: bool = true

func _ready():
	sprite.play("idle_mush")
	sprite.animation_finished.connect(_on_animation_finished)
	enemy_hitbox_collision.disabled = true

func _physics_process(delta):
	if estado_atual == Estados.MORTE:
		return

	if not is_on_floor():
		velocity.y += gravidade * delta

	if estado_atual == Estados.DANO or estado_atual == Estados.ATAQUE:
		velocity.x = 0
	else:
		if estado_atual == Estados.PATRULHA:
			patrulha()
		elif estado_atual == Estados.CACADA:
			cacada(delta)

	move_and_slide()

func patrulha():
	if estado_atual == Estados.PATRULHA:
		var tem_chao_a_frente = true
		if direcao == 1:
			if DetectorChaoDireita.get_overlapping_bodies().is_empty():
				tem_chao_a_frente = false
		elif direcao == -1:
			if DetectorChaoEsquerda.get_overlapping_bodies().is_empty():
				tem_chao_a_frente = false

		var deve_virar = false
		if not tem_chao_a_frente:
			deve_virar = true
		if is_on_wall():
			deve_virar = true
		
		if deve_virar and pode_virar:
			direcao *= -1
			pode_virar = false
			timerVira.start()
			velocity.x = 0
		else:
			velocity.x = direcao * velocidade

		if direcao == 1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
		sprite.play("run_mush")

func _on_timer_timeout():
	direcao = direcao * -1
	timer.start()

func _on_timer_2_timeout():
	pode_virar = true

func cacada(delta):
	if estado_atual != Estados.CACADA:
		return
		
	if player == null or not is_instance_valid(player):
		estado_atual = Estados.PATRULHA
		print("Player inválido, voltando a patrulhar.")
		return

	timer.stop()
	
	var pos_inimigo = self.global_position
	var pos_player = player.global_position
	var vetor_direcao = pos_player - pos_inimigo
	var distancia = vetor_direcao.length()

	if distancia <= distancia_ataque and pode_atacar:
		_iniciar_ataque()
		return
		
	var direcao_calculada = sign(vetor_direcao.x)
		
	if direcao_calculada != 0:
		direcao = direcao_calculada

	velocity.x = direcao * velocidade_maxima_x
		
	if direcao == 1:
		sprite.flip_h = true
	elif direcao == -1:
		sprite.flip_h = false
			
	sprite.play("run_mush")

func _on_area_2d_body_entered(body):
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO:
		return
		
	if body.is_in_group("Player"):
		print("Entrou na area")
		player = body
		if estado_atual == Estados.PATRULHA:
			estado_atual = Estados.CACADA

func _on_area_2d_body_exited(body):
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO:
		return
		
	if body == player:
		print("Saiu da area")
		player = null
		if estado_atual == Estados.CACADA:
			estado_atual = Estados.PATRULHA
			timer.start()

func _iniciar_ataque():
	if not pode_atacar: return
		
	print("Inimigo iniciando ataque!")
	estado_atual = Estados.ATAQUE
	pode_atacar = false
	velocity.x = 0
	sprite.play("attack_mush")
	enemy_hitbox_collision.set_deferred("disabled", false)
	
func take_damage(amount: int)-> void:
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO:
		return

	if estado_atual == Estados.ATAQUE:
		enemy_hitbox_collision.set_deferred("disabled", true)
		pode_atacar = true
		print("Ataque interrompido por dano.")

	vida_atual -= amount
	print("Inimigo tomou ", amount, " de dano. Vida restante: ", vida_atual)

	if vida_atual <= 0:
		estado_atual = Estados.MORTE
		_morrer()
	else:
		estado_atual = Estados.DANO
		sprite.play("damage_mush")
		
func _on_animation_finished():
	var anim_name = sprite.animation

	if anim_name == "damage_mush":
		if player != null and is_instance_valid(player) and AreaPlayer.has_overlapping_bodies():
			estado_atual = Estados.CACADA
		else:
			player = null
			estado_atual = Estados.PATRULHA
			timer.start()
			
	elif anim_name == "die_mush":
		queue_free()
		
	elif anim_name == "attack_mush":
		print("Inimigo terminou ataque.")
		enemy_hitbox_collision.set_deferred("disabled", true) 
		pode_atacar = true 

		if player != null and is_instance_valid(player) and AreaPlayer.has_overlapping_bodies():
			estado_atual = Estados.CACADA
		else:
			player = null
			estado_atual = Estados.PATRULHA
			timer.start()

func _morrer():
	print("Inimigo Morreu!")
	estado_atual = Estados.MORTE
	pode_atacar = false

	set_physics_process(false)

	if is_instance_valid(collision_shape):
		collision_shape.disabled = true
	if is_instance_valid(hurtbox):
		hurtbox.monitoring = false
		hurtbox.monitorable = false
	if is_instance_valid(AreaPlayer):
		AreaPlayer.monitoring = false
	if is_instance_valid(DetectorChaoDireita):
		DetectorChaoDireita.monitoring = false
	if is_instance_valid(DetectorChaoEsquerda):
		DetectorChaoEsquerda.monitoring = false
	if is_instance_valid(enemy_hitbox_collision):
		enemy_hitbox_collision.get_parent().monitoring = false

	if is_instance_valid(timer): timer.stop()
	if is_instance_valid(timerVira): timerVira.stop()

	if sprite != null and is_instance_valid(sprite):
		sprite.play("die_mush")
	else:
		queue_free()
