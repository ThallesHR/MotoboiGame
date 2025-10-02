extends Node2D
@onready var HeartContainer = $CanvasLayer2/heartsContainer
@onready var player = $CharacterBody2D

func _ready():
	HeartContainer.SetMaxHearths(player.vida_maxima)
	HeartContainer.UpdateHearts(player.vida_atual)
	player.healthChange.connect(HeartContainer.UpdateHearts)
