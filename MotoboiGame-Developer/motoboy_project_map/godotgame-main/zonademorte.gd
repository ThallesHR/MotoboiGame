extends Area2D

# Esta variável impede que o fade seja chamado 10x
# se o player ficar "batendo" na área enquanto morre.
var is_dying = false

# Esta é a sua função conectada ao sinal 'body_entered'
func _on_body_entered(body):
	
	# 1. Verifica se é o player E se ele já não está morrendo
	if body.is_in_group("Player") and not is_dying:
		is_dying = true 
		SceneTransition.reload_current_scene_with_fade()
