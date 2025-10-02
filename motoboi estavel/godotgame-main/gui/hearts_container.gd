extends HBoxContainer
@onready var HeartGuiClass = preload("res://gui/hearth.tscn")
var _current_value: int = 0

func SetMaxHearths(maxv:int):
	for i in range(maxv):
		var heart = HeartGuiClass.instantiate()
		add_child(heart)
	_current_value = maxv

func UpdateHearts(currentv:int):
	var Hearts =get_children()
	var previous_value = _current_value
	
	if currentv == previous_value:
		return
	if currentv > previous_value:
		for i in range(previous_value,currentv):
			Hearts[i].update(true)
	
	else: 
		var heart_index_to_animate = previous_value - 1
		Hearts[heart_index_to_animate].update(false)
		
	
		for i in range(previous_value - 2, currentv - 1, -1):
			Hearts[i].set_empty()
	
	
	_current_value = currentv
