class_name PlayerHP
extends ProgressBar


var player: PlayerAnimal


func set_player(p: PlayerAnimal):
	player = p

	print("PlayerHP connected to:", player)

	max_value = player.get_max_hp()
	value = player.hp

	if not player.hp_changed.is_connected(_on_player_hp_changed):
		player.hp_changed.connect(_on_player_hp_changed)


func _on_player_hp_changed(new_hp):
	print("PLAYER HP UI UPDATE:", new_hp)

	value = new_hp


 #Called every frame. 'delta' is the elapsed time since the previous frame.
 #func _process(delta: float) -> void:
 	#pass
