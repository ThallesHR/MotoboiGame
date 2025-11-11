# Salve este script como "InventarioManager.gd"
extends Node

signal inventario_mudou

# =================================================================
# DATABASE
# =================================================================
const DATABASE = {
	"punhos": {
		"nome": "Punhos", "descricao": "...", "tipo": "arma", 
		"textura": preload("res://items_icons/punhos.png") 
	},
	"capacete": {
		"nome": "Capacete", "descricao": "...", "tipo": "capacete",
		"textura": preload("res://items_icons/capacete.png") 
	},
	"hamburgao": {
		"nome": "Hamburgão Lendário", "descricao": "...",
		"tipo": "poder", # <--- Tipo "poder"
		"textura": preload("res://items_icons/hamburgao.png") 
	}
}

# =================================================================
# INVENTÁRIO
# =================================================================
var inventario = {
	"equipamento": {
		"arma": "punhos",
		"capacete": "capacete",
		"poder1": null,
		"poder2": null,
		"poder3": null,
		"poder4": null
	},
	"itens": [],
	"habilidades": []
}

# -----------------------------------------------------------------
# FUNÇÕES PÚBLICAS
# -----------------------------------------------------------------

# --- FUNÇÃO ADICIONAR_ITEM (CORRIGIDA) ---
func adicionar_item(item_id: String):
	if not DATABASE.has(item_id):
		return

	var tipo_item = DATABASE[item_id].tipo
	
	if tipo_item == "habilidade":
		# Habilidades vão direto para o grid "Habilidades"
		if not inventario.habilidades.has(item_id):
			inventario.habilidades.append(item_id)
			
	elif tipo_item == "poder":
		# CORREÇÃO: Poderes tentam equipar direto no primeiro slot vazio
		if inventario.equipamento.poder1 == null:
			inventario.equipamento.poder1 = item_id
		elif inventario.equipamento.poder2 == null:
			inventario.equipamento.poder2 = item_id
		elif inventario.equipamento.poder3 == null:
			inventario.equipamento.poder3 = item_id
		elif inventario.equipamento.poder4 == null:
			inventario.equipamento.poder4 = item_id
		else:
			# Slots cheios? Adiciona ao grid "Itens" como fallback
			print("Slots de poder cheios! '", item_id, "' foi para o inventário.")
			inventario.itens.append(item_id)
			
	else: 
		# "item", "arma", "capacete" vão para o grid "Itens"
		inventario.itens.append(item_id)

	# Avisa a UI em todos os casos
	inventario_mudou.emit()

# --- FUNÇÃO EQUIP_ITEM (Necessária para equipar do grid "Itens") ---
func equip_item(item_id: String):
	if not DATABASE.has(item_id) or not inventario.itens.has(item_id):
		return

	var dados_item = DATABASE[item_id]
	var tipo = dados_item.tipo

	if tipo == "poder":
		# Tenta equipar no primeiro slot de poder vazio
		if inventario.equipamento.poder1 == null:
			inventario.equipamento.poder1 = item_id
			inventario.itens.erase(item_id)
		elif inventario.equipamento.poder2 == null:
			inventario.equipamento.poder2 = item_id
			inventario.itens.erase(item_id)
		elif inventario.equipamento.poder3 == null:
			inventario.equipamento.poder3 = item_id
			inventario.itens.erase(item_id)
		elif inventario.equipamento.poder4 == null:
			inventario.equipamento.poder4 = item_id
			inventario.itens.erase(item_id)
		else:
			# Slots cheios, troca com o primeiro
			unequip_item("poder1")
			inventario.equipamento.poder1 = item_id 
			inventario.itens.erase(item_id) 

	# Lógica para arma, capacete, etc.
	elif inventario.equipamento.has(tipo):
		unequip_item(tipo) 
		inventario.equipamento[tipo] = item_id 
		inventario.itens.erase(item_id) 

	inventario_mudou.emit()

# --- FUNÇÃO UNEQUIP_ITEM ---
func unequip_item(slot_nome: String):
	if not inventario.equipamento.has(slot_nome):
		return
		
	var item_id_antigo = inventario.equipamento[slot_nome]
	
	if item_id_antigo != null:
		if item_id_antigo != "punhos": 
			inventario.itens.append(item_id_antigo)
		
		if slot_nome == "arma":
			inventario.equipamento[slot_nome] = "punhos"
		else:
			inventario.equipamento[slot_nome] = null
			
		inventario_mudou.emit()

# -----------------------------------------------------------------
# FUNÇÕES DE LEITURA
# -----------------------------------------------------------------

func get_dados_item(item_id) -> Dictionary:
	if item_id == null:
		return {"nome": "Vazio", "descricao": "Este slot está vazio.", "textura": null}
	if DATABASE.has(item_id):
		return DATABASE[item_id]
	return {"nome": "Vazio", "descricao": "Este slot está vazio.", "textura": null}

func get_equipamento() -> Dictionary:
	return inventario.equipamento

func get_itens_grid() -> Array:
	return inventario.itens

func get_habilidades_grid() -> Array:
	return inventario.habilidades


func is_power_equipped(power_id: String) -> bool:
	var equipamento = inventario.equipamento
	
	# Checa todos os 4 slots de poder
	if equipamento.poder1 == power_id:
		return true
	if equipamento.poder2 == power_id:
		return true
	if equipamento.poder3 == power_id:
		return true
	if equipamento.poder4 == power_id:
		return true
	
	# Se não achou em nenhum slot
	return false
