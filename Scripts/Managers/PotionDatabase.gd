extends Node
class_name PotionDatabase


var all_potions: Array[PotionResource] = []


func _ready() -> void:
	print("POTION DATABSE READY")


func initialize() -> void:

	all_potions.clear()

	_add_potion(
		"res://Data/Potions/SmallHealthPotion.tres"
	)

	_add_potion(
		"res://Data/Potions/LargeHealthPotion.tres"
	)

	_add_potion(
		"res://Data/Potions/AttackPotion.tres"
	)

	_add_potion(
		"res://Data/Potions/DefensePotion.tres"
	)

	_add_potion(
		"res://Data/Potions/SpeedPotion.tres"
	)

	print(
		"Total Potions:",
		all_potions.size()
	)


func _add_potion(path: String) -> void:

	var potion := load(path) as PotionResource

	if potion == null:

		push_error(
			"PotionDatabase: Failed to load: "
			+ path
		)

		return

	all_potions.append(potion)

	print(
		"Loaded Potion:",
		potion.potion_name
	)
