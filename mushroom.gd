extends CharacterBody2D
var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")
enum Estados{
	PATRULHA,CACADA
}
var velocidade :float = 40.0
var aceleracao: float = 20
var estado_atual = Estados.PATRULHA
var velocidade_maxima_x: float = 100.0
var direcao = 1
var player :CharacterBody2D = null
@onready var AreaPlayer:Area2D = $Area2D
@onready var timer:Timer = $Timer
@onready var timerVira:Timer = $Timer2
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
var pode_virar: bool = true
func _ready():
	$AnimatedSprite2D.play("idle_mush")
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade *delta
	if estado_atual == Estados.PATRULHA:
		patrulha()
	if estado_atual == Estados.CACADA:
		cacada()
	
	if is_on_wall()and pode_virar == true:
				direcao *= -1
				pode_virar = false
				$Timer2.start()

	move_and_slide()

func patrulha():
		if estado_atual == Estados.PATRULHA:
			velocity.x = direcao * velocidade
			sprite.flip_h = (direcao == 1) 
	
			$AnimatedSprite2D.play("run_mush")
	

func _on_timer_timeout():
	direcao = direcao * -1
	estado_atual = Estados.PATRULHA
	timer.start()


func _on_timer_2_timeout():
	pode_virar = true

func cacada():
	if estado_atual == Estados.CACADA:
		if player == null:
			estado_atual = Estados.PATRULHA
			return

		timer.stop()

		# --- INÍCIO DO DIAGNÓSTICO ---
		var pos_inimigo = self.global_position
		var pos_player = player.global_position
		var vetor_direcao = pos_player - pos_inimigo
		var direcao_calculada = sign(vetor_direcao.x) # sign() retorna -1, 0, ou 1

		print("==================")
		print("Pos Player: ", pos_player.x)
		print("Pos Inimigo: ", pos_inimigo.x)
		print("Vetor (Player - Inimigo): ", vetor_direcao.x)
		print("DIREÇÃO FINAL CALCULADA: ", direcao_calculada)
		# --- FIM DO DIAGNÓSTICO ---

		# Se o resultado for 0 (alinhado), mantenha a última direção
		if direcao_calculada != 0:
			direcao = direcao_calculada
		
		velocity.x = direcao * velocidade_maxima_x
		
		sprite.flip_h = (direcao == 1) # Lógica para sprite original virado para a ESQUERDA
					
		$AnimatedSprite2D.play("run_mush")
			


func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		print("Entrou na area")
		player = body
		estado_atual = Estados.CACADA



func _on_area_2d_body_exited(body):
	if body == player:
		print("Saiu da area")
		player = null
		estado_atual = Estados.PATRULHA
