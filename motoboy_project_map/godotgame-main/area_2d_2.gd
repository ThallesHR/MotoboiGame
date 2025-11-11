extends Area2D
@onready var interactable:Area2D = $Interactable
 
func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
		if sprite.frame == 0: 
			sprite.frame = 1 
			interactable.is_interactable = false
