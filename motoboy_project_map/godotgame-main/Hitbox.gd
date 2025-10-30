class_name Hitbox
extends Area2D
@export var damage := 10

func _ready() -> void:
	print("--- HITBOX (soco) PRONTO ---")
	print("Eu sou 'Monitorable'? ", monitorable) 
	print("Minha Camada (Layer) é: ", collision_layer) 
