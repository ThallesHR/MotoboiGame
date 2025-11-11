extends Control

signal text_box_finished # <-- 1. ADICIONE ESTA LINHA NO TOPO

@onready var label = $NinePatchRect/Label
@onready var text_timer = $TextTimer

var current_text = ""
var text_index = 0
var is_typing = false
var text_speed = 0.05

func _ready():
	hide()
	text_timer.timeout.connect(_on_text_timer_timeout)

func show_text_box(text_to_display: String):
	show()
	current_text = text_to_display
	label.text = ""
	text_index = 0
	is_typing = true
	text_timer.wait_time = text_speed
	text_timer.start()

func _on_text_timer_timeout():
	if text_index < current_text.length():
		label.text += current_text[text_index]
		text_index += 1
	else:
		is_typing = false
		text_timer.stop()

# 2. SUBSTITUA SUA FUNÇÃO _input POR ESTA:
func _input(event):
	if not is_visible():
		return # Não faça nada se a caixa não estiver visível

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Se estiver digitando, pule para o final
			label.text = current_text
			text_index = current_text.length()
			is_typing = false
			text_timer.stop()
		else:
			# Se já terminou de digitar, feche e avise (emita o sinal)
			hide()
			emit_signal("text_box_finished")
