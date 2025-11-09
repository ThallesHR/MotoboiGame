extends CharacterBody2D
@onready var interactable:Area2D = $Interactable
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var textbox:Control = $TextBox

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	interactable.interact = _on_interact
	
func _on_interact():
	if not GameState.tutorial_concluido:
		if sprite.frame == 0: 
			sprite.frame = 1 
			interactable.is_interactable = false
			textbox.show_text_box("???: Olá forasteiro você está perdido nesse mundo ?")
			await textbox.text_box_finished
			textbox.show_text_box("???: Creio que eu poderia te ajudar!!")
			await textbox.text_box_finished
			textbox.show_text_box("???: para se mover use o AD, para correr use SHIFT")
			await  textbox.text_box_finished
			textbox.show_text_box("???: para pular use espaço, e para se defender use mouse direito")
			await textbox.text_box_finished
			textbox.show_text_box("???: Esse mundo é hostil então lute para sobreviver!!")
			await textbox.text_box_finished
			textbox.show_text_box("???: boa sorte nesse caminho traiçoeiro...forasteiro")
			await  textbox.text_box_finished
			textbox.show_text_box("???: Por enquanto é só! vamos ver como se sai")
			await textbox.text_box_finished
			textbox.show_text_box("???: Adeus!!")
			await textbox.text_box_finished
			textbox.show_text_box("Motoboi: Quem é tu maluco !?")
			await textbox.text_box_finished
			
			# --- INÍCIO DO CÓDIGO PARA PULAR E SUMIR ---
			
			# 1. Toca a sua animação "voando" e espera ela terminar.
			if sprite.sprite_frames.has_animation("voando"):
				sprite.play("voando")
			await sprite.animation_finished # Ótima ideia esperar a animação terminar!
			
			# 2. Desabilita a colisão
			$CollisionShape2D.disabled = true
			$Interactable.get_node("CollisionShape2D").disabled = true 
			
			# 3. Cria um "Tween" para fazer a animação
			var tween = create_tween()
			
			# 4. ### MODIFICADO ###
			#    Define a posição de destino (diagonal)
			#    Vector2(X, Y)
			#    Vamos usar o seu Y (-300) e adicionar um X (ex: 300 para a direita).
			var target_position = global_position + Vector2(-300, -300)
			
			#    Descomente a linha abaixo (e comente a de cima) se quiser ir para Esquerda e Cima:
			# var target_position = global_position + Vector2(-300, -300)

			
			# 5. ### MODIFICADO ###
			#    Anima a "global_position" inteira (X e Y) para o destino.
			#    Estou usando a sua duração de 1.6 segundos.
			tween.tween_property(self, "global_position", target_position, 1.6)\
				.set_ease(Tween.EASE_IN)
			
			# 6. FAZ O PERSONAGEM DESAPARECER (FADE OUT) AO MESMO TEMPO.
			#    Estou usando a sua duração de 0.6 segundos.
			tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6)
			
			# 7. Espera a animação (Tween) terminar
			await tween.finished
			
			# 8. Remove o personagem da cena permanentemente
			queue_free()
		else:
			if sprite.frame == 0:
				sprite.frame = 1
				
			
			
		
		
		
