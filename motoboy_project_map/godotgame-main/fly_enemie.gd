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

@export var SMASH_SPEED: float = 400.0
var estado_ataque: String = "" # "preparar", "descida", "impacto", "subindo"
var altitude_ataque_y: float = 0.0

# --- MUDANÇA 1 ---
# Novas variáveis para a "memória" do inimigo
var last_attack_pos_x: float = 0.0 # Guarda o X do último ataque
@export var attack_pos_tolerance: float = 16.0 # Margem de erro (ex: 16 pixels)

@onready var hurtbox: Area2D = $HurtBox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var AreaPlayer:Area2D = $Area2D
@onready var timer:Timer = $Timer
@onready var timerVira:Timer = $Timer2
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hitbox_collision: CollisionShape2D = $EnemyHitbox/CollisionShape2D
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

var pode_virar: bool = true

func _ready():
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	enemy_hitbox_collision.disabled = true

func _physics_process(delta):
	if estado_atual == Estados.MORTE:
		velocity.y += gravidade * delta
		move_and_slide()
		return

	if estado_atual == Estados.DANO:
		velocity = Vector2.ZERO 
	
	elif estado_atual == Estados.ATAQUE:
		match estado_ataque:
			"preparar":
				velocity = Vector2.ZERO
			
			"descida":
				velocity.x = 0
				velocity.y = SMASH_SPEED
				
				if is_on_floor():
					_iniciar_impacto_chao() 
			
			"impacto":
				velocity = Vector2.ZERO
			
			# --- MUDANÇA 3 ---
			# Esta é a lógica principal (Passos 5, 6 e 7)
			"subindo":
				# Passo 7 (parcial): Verifica se o player sumiu
				if player == null or not is_instance_valid(player):
					estado_atual = Estados.PATRULHA
					estado_ataque = ""
					timer.start()
					return

				# Passo 4: Sobe
				velocity.x = 0
				velocity.y = -velocidade_maxima_x 
				
				# Verifica se já chegou na altitude original
				if self.global_position.y <= altitude_ataque_y:
					velocity = Vector2.ZERO 
					sprite.play("fly") 
					
					# Verifica se o cooldown acabou
					if pode_atacar:
						
						# --- LÓGICA DE DECISÃO ---
						# Passo 5: Verifica a posição do player
						var player_current_x = player.global_position.x
						
						# Passo 6a: Player está no mesmo lugar?
						if abs(player_current_x - last_attack_pos_x) <= attack_pos_tolerance:
							# SIM: Ataca o mesmo ponto (repete passo 2)
							print("PLAYER PARADO! Atacando mesmo local.")
							_iniciar_ataque()
						else:
							# NÃO: Player se moveu.
							# Passo 6b: Volta para CACADA para realinhar em X
							print("PLAYER MOVEU! Realinhando...")
							estado_atual = Estados.CACADA
							estado_ataque = ""
	
	elif estado_atual == Estados.PATRULHA:
		patrulha()
	
	elif estado_atual == Estados.CACADA:
		cacada(delta)

	move_and_slide()

func patrulha():
	if estado_atual == Estados.PATRULHA:
		var deve_virar = false
		if is_on_wall() and pode_virar: 
			deve_virar = true
		
		if deve_virar:
			direcao *= -1
			pode_virar = false
			timerVira.start()
			velocity.x = 0
		else:
			velocity.x = direcao * velocidade

		velocity.y = sin(Time.get_ticks_msec() * 0.002) * 15.0

		if direcao == 1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
		sprite.play("idle")

func _on_timer_timeout():
	direcao = direcao * -1
	timer.start()

func _on_timer_2_timeout():
	pode_virar = true

func cacada(delta):
	# Passo 1: Detecta o player
	if estado_atual != Estados.CACADA:
		return
	# Passo 7 (parcial): Se não há player
	if player == null or not is_instance_valid(player):
		estado_atual = Estados.PATRULHA
		return

	timer.stop()
	
	var pos_inimigo = self.global_position
	var pos_player = player.global_position
	
	var direcao_x = sign(pos_player.x - pos_inimigo.x)
	var distancia_horizontal = abs(pos_player.x - pos_inimigo.x)

	if distancia_horizontal <= distancia_ataque and pode_atacar:
		_iniciar_ataque() # Passo 2: Inicia o ataque
		return
		
	# Passo 6b (Execução): "vá em x na mesma linha que o player"
	velocity.x = direcao_x * velocidade_maxima_x
	velocity.y = sin(Time.get_ticks_msec() * 0.002) * 15.0
	
	if direcao_x > 0:
		sprite.flip_h = true
	elif direcao_x < 0:
		sprite.flip_h = false
	
	sprite.play("fly")

func _on_area_2d_body_entered(body):
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO: return
	if body.is_in_group("Player"):
		player = body
		if estado_atual == Estados.PATRULHA:
			estado_atual = Estados.CACADA

func _on_area_2d_body_exited(body):
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO or estado_atual == Estados.ATAQUE:
		return
	if body == player:
		player = null
		if estado_atual == Estados.CACADA:
			estado_atual = Estados.PATRULHA
			timer.start()

func _iniciar_ataque():
	if not pode_atacar: return
		
	print("Inimigo iniciando SMASH!")
	estado_atual = Estados.ATAQUE
	estado_ataque = "preparar" 
	pode_atacar = false 
	
	velocity = Vector2.ZERO 
	
	# --- MUDANÇA 2 ---
	# Salva a posição X exata deste ataque
	last_attack_pos_x = self.global_position.x
	
	altitude_ataque_y = self.global_position.y
	
	sprite.play("smash_start") 
	
	enemy_hitbox_collision.set_deferred("disabled", true)

func _iniciar_impacto_chao():
	if estado_ataque == "impacto":
		return 
		
	print("Inimigo atingiu o chão!")
	estado_ataque = "impacto"
	velocity = Vector2.ZERO 
	
	sprite.play("smash_end")
	
	enemy_hitbox_collision.set_deferred("disabled", true)
	
func take_damage(amount: int)-> void:
	# Passo 3: Toma o dano
	if estado_atual == Estados.MORTE or estado_atual == Estados.DANO:
		return

	if estado_atual == Estados.ATAQUE:
		enemy_hitbox_collision.set_deferred("disabled", true)
		estado_ataque = "" 
		print("Ataque SMASH interrompido por dano.")
	
	pode_atacar = false
	attack_cooldown_timer.start()

	vida_atual -= amount
	print("Inimigo tomou ", amount, " de dano. Vida restante: ", vida_atual)

	if vida_atual <= 0:
		estado_atual = Estados.MORTE
		_morrer()
	else:
		estado_atual = Estados.DANO
		sprite.play("hit")
		
func _on_animation_finished():
	var anim_name = sprite.animation

	if estado_atual == Estados.ATAQUE:
		if anim_name == "smash_start":
			estado_ataque = "descida"
			sprite.play("smash_loop")
			enemy_hitbox_collision.set_deferred("disabled", false)
			return 
			
		elif anim_name == "smash_end":
			print("Inimigo terminou impacto, subindo...")
			# Inicia o Passo 4 (Subir)
			estado_ataque = "subindo"
			sprite.play("fly") 
			enemy_hitbox_collision.set_deferred("disabled", true) 
			
			pode_atacar = false 
			attack_cooldown_timer.start()
			
			return 

	if anim_name == "hit":
		# Fim do Passo 3 (Dano)
		if player != null and is_instance_valid(player):
			
			if altitude_ataque_y == 0.0:
				altitude_ataque_y = self.global_position.y
			
			# Inicia o Passo 4 (Subir)
			estado_atual = Estados.ATAQUE
			estado_ataque = "subindo"
		else:
			# Passo 7 (parcial): Player sumiu
			player = null
			estado_atual = Estados.PATRULHA
			timer.start()
			
	elif anim_name == "die":
		queue_free()

func _morrer():
	print("Inimigo Morreu!")
	estado_atual = Estados.MORTE
	pode_atacar = false
	estado_ataque = "" 

	if is_instance_valid(collision_shape):
		collision_shape.disabled = true
	if is_instance_valid(hurtbox):
		hurtbox.monitoring = false
		hurtbox.monitorable = false
	if is_instance_valid(AreaPlayer):
		AreaPlayer.monitoring = false
	if is_instance_valid(enemy_hitbox_collision):
		enemy_hitbox_collision.get_parent().monitoring = false

	if is_instance_valid(timer): timer.stop()
	if is_instance_valid(timerVira): timer.stop()

	if sprite != null and is_instance_valid(sprite):
		sprite.play("die")
	else:
		queue_free()

func _on_attack_cooldown_timer_timeout():
	pode_atacar = true
	print("INIMIGO: Cooldown terminou. Pode atacar.")
