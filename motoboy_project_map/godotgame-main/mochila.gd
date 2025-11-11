extends Area2D
@export var float_amplitude: float = 6.0
@export var float_speed: float = 4.0
@onready var interactable:Area2D = $Interactable
@onready var sprite = $AnimatedSprite2D
@onready var textbox:Control = $TextBox

var start_position_y: float = 0.0

func _ready():
	interactable.interact = _on_interact
	if sprite != null:
		start_position_y = sprite.position.y
	else:
		print("ERRO: Nó de sprite não encontrado!")

func _process(delta):
	if sprite != null:
		var time_sec = Time.get_ticks_msec() / 1000.0
		var new_y_offset = sin(time_sec * float_speed) * float_amplitude
		sprite.position.y = start_position_y + new_y_offset


		
func _on_interact(player_body):
	if player_body.has_method("set_input_enabled"):
		player_body.set_input_enabled(false)
		if sprite.frame == 0: 
				sprite.frame = 1
				interactable.is_interactable = false
				if player_body.has_method("play_animation_and_wait"):
					await player_body.play_animation_and_wait("pegar_item")
				textbox.show_text_box("Você vincula sua alma e energia a lendária mochila")
				await textbox.text_box_finished
				textbox.show_text_box("Ela sente que você é destinado a ser o portador dela")
				await textbox.text_box_finished
				textbox.show_text_box("Você sente sua alma mudar, sente um poder crescente dentro do seu corpo")
				await textbox.text_box_finished
				textbox.show_text_box("Algo está diferente em você")
				await textbox.text_box_finished
				InventoryManager.adicionar_item("hamburgao")
				print("TESTE: Inventário de equipamento agora é:", InventoryManager.get_equipamento())
				queue_free()

		if player_body.has_method("set_input_enabled"):
			player_body.set_input_enabled(true)
			
		
