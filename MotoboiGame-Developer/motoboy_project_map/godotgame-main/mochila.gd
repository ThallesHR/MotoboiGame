extends Area2D
@export var float_amplitude: float = 6.0
@export var float_speed: float = 4.0
   
@onready var sprite = $AnimatedSprite2D

var start_position_y: float = 0.0

func _ready():
	if sprite != null:
		start_position_y = sprite.position.y
	else:
		print("ERRO: Nó de sprite não encontrado!")

func _process(delta):
	if sprite != null:
		var time_sec = Time.get_ticks_msec() / 1000.0
		var new_y_offset = sin(time_sec * float_speed) * float_amplitude
		sprite.position.y = start_position_y + new_y_offset
