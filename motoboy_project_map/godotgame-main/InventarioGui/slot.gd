# Salve este script como "Slot.gd"
extends TextureButton

# Sinal que avisa a GUI qual item foi clicado
signal slot_clicado(item_id)

var item_id = ""

# Referência ao nó Sprite2D que se chama "Icone"
# (Se você deu outro nome, mude "$Icone" aqui)
@onready var item_icone: Sprite2D = $Icone 

func _ready():
	pressed.connect(_on_pressed)
	# Garante que o ícone comece ESCONDIDO
	item_icone.visible = false

# Função principal chamada pela GUI
func setup(id):
	item_id = id
	
	if id != null:
		var dados = InventoryManager.get_dados_item(id)
		
		# --- ADICIONE ESTA LINHA DE TESTE ---
		print("Slot ", self.name, " recebeu setup com ID '", id, "'. Dados da textura: ", dados.textura)
		# --- FIM DA LINHA DE TESTE ---
		
		if dados.textura != null:
			item_icone.visible = true
			item_icone.texture = dados.textura
			item_icone.hframes = 1
		else:
			setup(null) # Trata item inválido como vazio
	else:
		item_icone.visible = false

func _on_pressed():
	if item_id != "" and item_id != null:
		slot_clicado.emit(item_id)
		
