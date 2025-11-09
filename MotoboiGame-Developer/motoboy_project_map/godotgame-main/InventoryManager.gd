extends Node

# Sinal que "avisa" a UI (Tela) quando algo muda
signal inventario_mudou

# =================================================================
# O "DICIONÁRIO" DE TODOS OS ITENS DO JOGO
# É aqui que guardamos o "nome", "descrição" e "textura"
# de CADA item que pode existir.
# =================================================================
const DATABASE = {
	# --- Armas ---
	"punhos": {
		"nome": "Punhos",
		"descricao": "Nada melhor do que a velha porrada pra resolver",
		"tipo": "arma", # Tipo usado para saber onde equipar
		"textura": preload("res://items_icons/punhos.png") # MUDE O CAMINHO
	},
	
	# --- Equipamentos ---
	"capacete": {
		"nome": "Capacete",
		"descricao": "Um Capacete de moto velho e gasto.",
		"tipo": "capacete", # Tipo usado para saber onde equipar
		"textura": preload("res://items_icons/capacete.png") # MUDE O CAMINHO
	},
	
	# --- Itens (Vão para o Grid) ---
	"hamburgao": {
		"nome": "Hamburgão Lendário",
		"descricao": "A forma mais forte da sua energia.",
		"tipo": "item", # "item" significa que fica no grid
		"textura": preload("res://items_icons/hamburgao.png") # MUDE O CAMINHO
	}
}

# =================================================================
# O "INVENTÁRIO" DO JOGADOR
# O que o jogador TEM AGORA. (Atualizado para o novo design)
# =================================================================
var inventario = {
	# Um dicionário para os 6 slots de equipamento
	"equipamento": {
		"arma": "punhos", # Começa com a arma padrão
		"escudo": null,
		"capacete": "capacete",
		"armadura": null,
		"acessorio1": null,
		"acessorio2": null
	},
	
	# Uma lista para TODOS os outros itens (o grid "ITEMS")
	"itens": []
}

# -----------------------------------------------------------------
# FUNÇÕES PÚBLICAS (Que outros scripts vão chamar)
# -----------------------------------------------------------------

## ADICIONA UM ITEM AO GRID "ITEMS"
# (É o que a sua "Mochila.gd" deve chamar)
func adicionar_item(item_id: String):
	if not DATABASE.has(item_id):
		print("ERRO: Item '", item_id, "' não existe no DATABASE!")
		return

	# Adiciona o item à lista (grid) de itens
	inventario.itens.append(item_id)
	print("Item '", item_id, "' adicionado ao inventário (grid).")
	
	# "Avisa" a UI (Tela) que o inventário mudou!
	inventario_mudou.emit()

## EQUIPA UM ITEM (Tira do grid "itens" e bota no slot "equipamento")
# (É o que a sua UI vai chamar quando o player clicar num item do grid)
func equip_item(item_id: String):
	# 1. Verifica se o item existe e se o player o possui no grid
	if not DATABASE.has(item_id) or not inventario.itens.has(item_id):
		return

	var dados_item = DATABASE[item_id]
	var tipo = dados_item.tipo

	# 2. Verifica se é um acessório (caso especial de 2 slots)
	if tipo == "acessorio":
		# Tenta equipar no slot 1
		if inventario.equipamento.acessorio1 == null:
			inventario.equipamento.acessorio1 = item_id
			inventario.itens.erase(item_id) # Remove do grid
		# Tenta equipar no slot 2
		elif inventario.equipamento.acessorio2 == null:
			inventario.equipamento.acessorio2 = item_id
			inventario.itens.erase(item_id) # Remove do grid
		else:
			# Slots cheios, troca com o primeiro
			unequip_item("acessorio1") # Desequipa o item antigo
			inventario.equipamento.acessorio1 = item_id # Equipa o novo
			inventario.itens.erase(item_id) # Remove do grid
	
	# 3. Verifica se é um tipo de equipamento padrão (arma, capacete, etc.)
	elif inventario.equipamento.has(tipo):
		unequip_item(tipo) # Desequipa o item antigo (se houver)
		inventario.equipamento[tipo] = item_id # Equipa o novo item
		inventario.itens.erase(item_id) # Remove do grid

	# 4. Avisa a UI para se atualizar
	inventario_mudou.emit()

## DESEQUIPA UM ITEM (Tira do slot "equipamento" e devolve ao grid "itens")
# (É o que a UI vai chamar se o player clicar num item *equipado*)
func unequip_item(slot_nome: String): # ex: "arma", "capacete", "acessorio1"
	if not inventario.equipamento.has(slot_nome):
		return
		
	# 1. Pega o ID do item que está no slot
	var item_id_antigo = inventario.equipamento[slot_nome]
	
	# 2. Se o slot não estava vazio...
	if item_id_antigo != null:
		# 3. Esvazia o slot
		inventario.equipamento[slot_nome] = null
		# 4. Devolve o item antigo para o grid "itens"
		inventario.itens.append(item_id_antigo)
		
		# 5. Avisa a UI
		inventario_mudou.emit()


# -----------------------------------------------------------------
# FUNÇÕES DE LEITURA (Para a UI saber o que desenhar)
# -----------------------------------------------------------------

## Pega os dados de um item (nome, desc, textura)
func get_dados_item(item_id: String) -> Dictionary:
	if DATABASE.has(item_id):
		return DATABASE[item_id]
	# Retorna um dicionário vazio se o item_id for nulo ou inválido
	return {"nome": "Vazio", "descricao": "Este slot está vazio.", "textura": null}

## Pega o dicionário inteiro de itens equipados
func get_equipamento() -> Dictionary:
	return inventario.equipamento

## Pega a lista de itens no grid
func get_itens_grid() -> Array:
	return inventario.itens
