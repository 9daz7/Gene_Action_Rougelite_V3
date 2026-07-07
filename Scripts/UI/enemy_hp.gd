class_name EnemyHP
extends ProgressBar

var enemy: Enemies

func set_enemy(e: Enemies):
	enemy = e
	
	print("EnemyHP connected to:", enemy)
	
	max_value = enemy.max_hp
	value = enemy.hp
		
	if enemy.hp_changed.is_connected(_on_enemy_hp_changed):
		enemy.hp_changed.disconnect(_on_enemy_hp_changed)
		
	enemy.hp_changed.connect(_on_enemy_hp_changed)
	
func _on_enemy_hp_changed(new_hp):
	print("ENEMY HP UI UPDATE:", new_hp)
	value = new_hp
	
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
