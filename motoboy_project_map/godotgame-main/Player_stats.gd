
extends Resource
class_name StatsP

signal health_depleted
signal health_changed(current_health:int, max_health:int)

@export var max_health: int = 5
@export var base_attack: int = 30

var current_max_health: int
var current_attack: int

var health: int = 0: set = _on_health_set



func setup_stats() -> void:

	current_max_health = max_health
	current_attack = base_attack
	

	health = current_max_health
	print("Stats configurados! Vida: ", health)

func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()


func take_damage(damage_amount: int) -> void:
	if damage_amount > 0:
		# Usar 'health =' ativa o setter _on_health_set
		health -= damage_amount
		print("Inimigo tomou ", damage_amount, " de dano. Vida restante: ", health)
	else:
		print("Dano bloqueado pela defesa!")
