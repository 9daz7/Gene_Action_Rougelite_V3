extends CharacterBody3D

signal health_changed(current_health: float, max_health: float)
signal died

@export var enemy_data: EnemyResource

var max_health: float
var health: float

const DAMAGE_NUMBER_SCENE: PackedScene = preload(
	"res://Scenes/Test3D/DamageNumber.tscn"
)


func _ready() -> void:

	if enemy_data == null:
		push_error("Enemy data has not been assigned.")
		return

	max_health = enemy_data.base_hp
	health = max_health


func take_damage(amount: float) -> void:

	if amount <= 0.0 or health <= 0.0:
		return

	var previous_health := health
	health = maxf(health - amount, 0.0)

	var actual_damage := previous_health - health

	health_changed.emit(health, max_health)

	show_damage_number(actual_damage)

	print(enemy_data.enemy_name, " health: ", health, " / ", max_health)

	if health <= 0.0:
		_die()


func show_damage_number(amount: float) -> void:

	var damage_number = DAMAGE_NUMBER_SCENE.instantiate()

	get_tree().current_scene.add_child(damage_number)

	damage_number.global_position = global_position + Vector3.UP * 1.0
	damage_number.set_damage(amount)


func _die() -> void:

	died.emit()
	queue_free()
