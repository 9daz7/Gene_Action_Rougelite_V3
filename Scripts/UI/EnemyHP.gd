class_name EnemyHP
extends ProgressBar


var enemy: EnemyAnimal


func set_enemy(e: EnemyAnimal):
	enemy = e

	print("EnemyHP connected to:", enemy)

	max_value = enemy.get_max_hp()
	value = enemy.hp

	if not enemy.hp_changed.is_connected(_on_enemy_hp_changed):
		enemy.hp_changed.connect(_on_enemy_hp_changed)


func _on_enemy_hp_changed(new_hp):
	print("ENEMY HP UI UPDATE:", new_hp)

	value = new_hp
