extends Panel
@onready var sprite = $AnimatedSprite2D
func _ready():
	sprite.play("hearth_max")
	
func update(whole:bool):
	if whole: sprite.play("hearth_max")
	else: 
		sprite.play("hearth_damage")
		await sprite.animation_finished
		sprite.play("hearth_nolife")

func set_empty():
	sprite.play("hearth_nolife")
	
