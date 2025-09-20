extends CharacterBody2D
var gravidade:float = 100.0
var timer_andar:float = 5.0
var velocidade_maxima_x:float = 40.00
var direcao: int = 1
var cacada_velocidade:float = 80.00
enum States{
	CACADA,PATRULHA
	}
var estado_mush = States.PATRULHA
@export var  player:CharacterBody2D
@onready var detector: Area2D = $detector
@onready var timer: Timer = $Timer
func _ready():
	$AnimatedSprite2D.play("idle_mush")
	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade * delta
	andar()
	
	move_and_slide()
	
		
		

func andar():
	var velocidade_atual : float = 0.0

	# 1. Decide a velocidade e a direção
	if estado_mush == States.PATRULHA:
		velocidade_atual = velocidade_maxima_x
	elif estado_mush == States.CACADA:
		velocidade_atual = cacada_velocidade
		# Se o jogador não se moveu, direcao pode ser 0. Mantemos a última direção.
		var nova_direcao = sign(player.global_position.x - self.global_position.x)
		if nova_direcao != 0:
			direcao = nova_direcao

	# 2. Aplica o movimento
	velocity.x = velocidade_atual * direcao

	# 3. Atualiza o visual com base no movimento REAL
	if velocity.x > 0: # Movendo para a DIREITA
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("run_mush")
	elif velocity.x < 0: # Movendo para a ESQUERDA
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("run_mush")
	else: # Parado
		$AnimatedSprite2D.play("idle_mush")

			
func _on_timer_timeout() -> void:
	direcao *= -1
	print("andar")
	timer.start()


func _on_detector_body_entered(body) -> void:
	if body == player:
		estado_mush =States.CACADA
		timer.stop()


func _on_detector_body_exited(body) -> void:
	if body == player:
		estado_mush = States.PATRULHA
		timer.start()
