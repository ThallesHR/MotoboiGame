extends Node2D
@onready var HeartContainer = $CanvasLayer/heartsContainer
@onready var player = $CharacterBody2D

func _ready():
	pass
#	HeartContainer.SetMaxHearths(player.vida_maxima)
	#HeartContainer.UpdateHearts(player.vida_atual)
	#player.healthChange.connect(HeartContainer.UpdateHearts)
