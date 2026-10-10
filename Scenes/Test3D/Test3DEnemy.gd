extends CharacterBody3D

signal health_changed(current_health: float, max_health: float)
signal died

@export var enemy_data: EnemyResource

var max_health: float
var health: float


func _ready() -> void:
	if enemy_data == null:
		push_error("Enemy data has not been assigned.")
		return

	max_health = enemy_data.base_hp
	health = max_health


func take_damage(amount: float) -> void:
	if amount <= 0.0 or health <= 0.0:
		return

	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)

	print(enemy_data.enemy_name, " health: ", health, " / ", max_health)

	if health <= 0.0:
		_die()


func _die() -> void:
	died.emit()
	queue_free()
