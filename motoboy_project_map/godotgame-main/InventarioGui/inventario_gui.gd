# Salve este script como "InventarioGui.gd"
extends Control 

# =================================================================
# 1. REFERÊNCIAS AOS NÓS (Mapeamento Corrigido)
# =================================================================
@onready var grid_itens: GridContainer = $NinePatchRect/GridItens
@onready var grid_habilidades: GridContainer = $NinePatchRect/GridHabilidades

# --- Slots de Equipamento (Mapeamento Corrigido) ---
@onready var slot_arma: Control = $NinePatchRect/Control/SlotPunhos
@onready var slot_capacete: Control = $NinePatchRect/Control/SlotCapacete
# CORREÇÃO: Mapeia os nós da UI para os slots do Manager
@onready var slot_poder1: Control = $NinePatchRect/Control/SlotPoder1
@onready var slot_poder2: Control = $NinePatchRect/Control/SlotPoder2
@onready var slot_poder3: Control = $NinePatchRect/Control/SlotPoder3
@onready var slot_poder4: Control = $NinePatchRect/Control/SlotPoder4

# =================================================================
# 2. LÓGICA DO INVENTÁRIO
# =================================================================

func _ready():
	# 1. Conecta ao sinal do manager
	InventoryManager.inventario_mudou.connect(atualizar_ui)
	
	# 2. Conecta os cliques dos slots de EQUIPAMENTO (Mapeamento Corrigido)
	slot_arma.slot_clicado.connect(_on_equip_slot_clicado.bind("arma"))
	slot_capacete.slot_clicado.connect(_on_equip_slot_clicado.bind("capacete"))
	slot_poder1.slot_clicado.connect(_on_equip_slot_clicado.bind("poder1"))
	slot_poder2.slot_clicado.connect(_on_equip_slot_clicado.bind("poder2"))
	slot_poder3.slot_clicado.connect(_on_equip_slot_clicado.bind("poder3"))
	slot_poder4.slot_clicado.connect(_on_equip_slot_clicado.bind("poder4"))
	
	# 3. Conecta os cliques dos slots dos GRIDS
	for slot in grid_itens.get_children():
		slot.slot_clicado.connect(_on_grid_item_clicado) 
		
	for slot in grid_habilidades.get_children():
		slot.slot_clicado.connect(_on_grid_habilidade_clicado)

	# 4. Começa escondido e atualiza a UI
	hide()
	atualizar_ui()
	
	# 5. Define o Process Mode para "Always" para poder abrir/fechar
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if Input.is_action_just_pressed("abrir_inventario"):
		visible = not visible
		get_tree().paused = visible

# --- FUNÇÕES DE ATUALIZAÇÃO DA UI (Mapeamento Corrigido) ---

func atualizar_ui():
	atualizar_equipamento()
	atualizar_grid_estatico(grid_itens, InventoryManager.get_itens_grid())
	atualizar_grid_estatico(grid_habilidades, InventoryManager.get_habilidades_grid())

func atualizar_equipamento():
	var equipamento = InventoryManager.get_equipamento()
	
	# CORREÇÃO: Pede ao setup para desenhar os itens dos slots corretos
	slot_arma.setup(equipamento.arma)
	slot_capacete.setup(equipamento.capacete)
	slot_poder1.setup(equipamento.poder1) # <--- Agora ele vai pedir "poder1"
	slot_poder2.setup(equipamento.poder2)
	slot_poder3.setup(equipamento.poder3)
	slot_poder4.setup(equipamento.poder4)

func atualizar_grid_estatico(grid: GridContainer, lista_ids: Array):
	var slots = grid.get_children()
	
	for i in range(slots.size()):
		if i < lista_ids.size():
			slots[i].setup(lista_ids[i])
		else:
			slots[i].setup(null)

# --- FUNÇÕES DE CALLBACK (O que fazer ao clicar) ---

func _on_grid_item_clicado(item_id: String):
	# Esta função agora vai equipar o "poder" (se ele cair no grid)
	InventoryManager.equip_item(item_id)

func _on_equip_slot_clicado(slot_nome: String):
	# Esta função agora vai desequipar o "poder"
	InventoryManager.unequip_item(slot_nome)

func _on_grid_habilidade_clicado(item_id: String):
	# Habilidades (como "dash") não fazem nada ao clicar
	var dados = InventoryManager.get_dados_item(item_id)
	print("Clicou na HABILIDADE (passiva): ", dados.nome)
