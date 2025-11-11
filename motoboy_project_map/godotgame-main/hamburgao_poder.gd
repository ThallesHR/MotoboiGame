# Script "HamburgaoProjetil.gd"
extends Area2D

var velocidade = 500
var direcao = 1 # 1 para direita, -1 para esquerda

func _physics_process(delta):
	# Move o projétil
	position.x += velocidade * direcao * delta

# Conecte o sinal "body_entered" do Area2D a esta função
func _on_body_entered(body):
	if body.is_in_group("enemies"): # (Supondo que seus inimigos estão no grupo "inimigos")
		body.take_damage(10) # Chama a função de dano no inimigo
		pass
	
	queue_free()




func _on_timer_timeout() -> void:
	queue_free()
