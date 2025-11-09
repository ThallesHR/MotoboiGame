extends Node2D
@onready var HeartContainer = $CanvasLayer2/heartsContainer
@onready var player = $CharacterBody2D

func _ready():
	HeartContainer.SetMaxHearths(player.vida_maxima)
	HeartContainer.UpdateHearts(player.vida_atual)
	player.healthChange.connect(HeartContainer.UpdateHearts)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ALGUÉM ENTROU NA ÁREA: ", body.name)
	if body.is_in_group("Player"):
		print("É O JOGADOR! Trocando de cena...")
		get_tree().change_scene_to_file("res://forestscene2.tscn")
	else:
		print("Não é o jogador. Ignorando.")
