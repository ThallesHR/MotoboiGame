class_name HurtBox
extends Area2D


	
func _ready() -> void:
	print("--- HURTBOX (inimigo) PRONTO ---")
	print("Meu 'Owner' é: ", owner.name)
	print("Eu sou 'Monitoring'? ", monitoring) 
	print("Minha Máscara (Mask) é: ", collision_mask)
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hitbox: Hitbox)->void:
	if hitbox == null:
		return
		
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	print("!!! HURTBOX: ÁREA DETECTADA: ", hitbox.name)
		
