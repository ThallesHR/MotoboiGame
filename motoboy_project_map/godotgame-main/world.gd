extends Node2D
@onready var HeartContainer = $CanvasLayer2/heartsContainer
@onready var player = $CharacterBody2D

func _ready():
	HeartContainer.SetMaxHearths(player.vida_maxima)
	HeartContainer.UpdateHearts(player.vida_atual)
	player.healthChange.connect(HeartContainer.UpdateHearts)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://forestscene2.tscn")
	else:
		return
