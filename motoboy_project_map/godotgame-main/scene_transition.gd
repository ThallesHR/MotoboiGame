# Em SceneTransition.gd

extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready():
	# 1. Conecta o sinal "scene_changed" (cena mudou) 
	#    para a nossa função "_on_scene_changed".
	get_tree().scene_changed.connect(_on_scene_changed)
	
	# 2. Roda a função uma vez manualmente para
	#    fazer o fade-in da *primeira* cena.
	_on_scene_changed()

# Esta função agora será chamada AUTOMATICAMENTE
# toda vez que uma cena for carregada (incluindo reload).
func _on_scene_changed():
	# Garante que a cena comece preta
	color_rect.color.a = 1.0 # 1.0 = Alfa 255 (Opaco)
	
	# Toca a animação "fade_in" para revelar a cena
	anim_player.play("fade_in")

# Esta é a função que a ZonaDeMorte chama.
# Ela não muda.
func reload_current_scene_with_fade():
	# 1. Toca o "piscar" para o preto
	anim_player.play("fade_out")
	
	# 2. Espera a animação terminar
	await anim_player.animation_finished
	
	# 3. Recarrega a cena.
	get_tree().reload_current_scene()
	
	# 4. Assim que a cena recarregar, o Godot vai disparar
	#    o sinal "scene_changed", que chamará
	#    a nossa função "_on_scene_changed" e fará o fade_in.
