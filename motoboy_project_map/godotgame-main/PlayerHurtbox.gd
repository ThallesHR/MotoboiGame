# PlayerHurtbox.gd
class_name PlayerHurtbox
extends Area2D

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: EnemyHitbox): 
	# VERIFICAÇÃO 1: O hitbox em si é válido?
	if not is_instance_valid(hitbox):
		return
		
	# VERIFICAÇÃO 2 (A MAIS IMPORTANTE): O dono do hitbox (o Inimigo) ainda existe?
	if not is_instance_valid(hitbox.owner):
		print("PlayerHurtbox: Detectou hit, mas o Inimigo já está morto. Dano ignorado.")
		return # Ignora o dano se o inimigo já foi liberado
		
	# Se tudo estiver válido, prossiga
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage, hitbox.owner) 
	else:
		print("AVISO: Player não tem a função take_damage!")
