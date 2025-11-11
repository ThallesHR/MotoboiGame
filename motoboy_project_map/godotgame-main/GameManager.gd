extends Node
const SAVE_PATH = "user://save_game.dat"
var player_ref: Node = null
func set_player(player: Node):
	player_ref = player
func heal_player_fully():
	if is_instance_valid(player_ref):
		player_ref.vida_atual = player_ref.vida_maxima
		print("GAME MANAGER: Player curado!")
	else:
		print("GAME MANAGER: Erro! Referência do player é inválida.")
func save_game():
	if !is_instance_valid(player_ref):
		print("GAME MANAGER: Não é possível salvar. Referência do player é inválida.")
		return
	var save_data = {
		"scene_path": get_tree().current_scene.scene_file_path,
		"player_health": player_ref.vida_atual,
		"player_max_health": player_ref.vida_maxima,
		"player_position_x": player_ref.global_position.x,
		"player_position_y": player_ref.global_position.y,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("GAME MANAGER: Jogo salvo com sucesso em ", SAVE_PATH)
		print("Dados salvos: ", save_data)
	else:
		print("GAME MANAGER: Erro ao tentar salvar o jogo.")
