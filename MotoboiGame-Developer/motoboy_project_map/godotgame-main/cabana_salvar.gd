extends CharacterBody2D
@onready var interactable:Area2D = $Interactable
@onready var sprite:Sprite2D = $Sprite2D
@onready var textbox:Control = $TextBox
 
func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
		if sprite.frame == 0: 
			sprite.frame = 1
			interactable.is_interactable = false
			GameManager.heal_player_fully()
			GameManager.save_game()
			textbox.show_text_box("Descansar nessa cabana te deixa cheio de preguiça e fome")
			await textbox.text_box_finished
			textbox.show_text_box("Mas tu não pode dormir poha!, tem que ir arrumar a nave!")
			await textbox.text_box_finished
			textbox.show_text_box("Game Salvo!")
			await textbox.text_box_finished
			interactable.is_interactable = true
			
