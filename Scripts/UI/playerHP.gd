class_name PlayerHP
extends ProgressBar

var player: PlayerAnimal

func set_player(p: PlayerAnimal):
	player = p
	
	max_value = player.get_max_hp()
	value = player.hp
	
	#if player.hp_changed.is_connected(_on_hp_changed):
		#player.hp_changed.disconnect(_on_hp_changed)
		
	player.hp_changed.connect(_on_hp_changed)
#func _ready():
	#max_value = player.max_hp
	#value = player.hp
	#
	#player.hp_changed.connect(_on_hp_changed)
	
func _on_hp_changed(new_hp):
	value = new_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
