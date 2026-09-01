extends Node
class_name PotionStorageManager

# ==================================================
# Settings
# ==================================================

@export var starting_storage_capacity: int = 10


# ==================================================
# Stored Potions
# ==================================================

var stored_potions: Dictionary = {}


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("POTION STORAGE MANAGER READY")


# ==================================================
# Storage
# ==================================================

func add_potion(
	potion: PotionResource,
	amount: int = 1
) -> bool:

	if potion == null:
		return false

	if amount <= 0:
		return false

	var current: int = stored_potions.get(
		potion,
		0
	)

	stored_potions[potion] = (
		current + amount
	)

	return true


func move_potion_to_run(
	potion: PotionResource,
	run_manager: RunManager
) -> bool:

	if potion == null:
		return false

	if run_manager == null:
		return false

	if get_potion_count(potion) <= 0:
		return false

	if not run_manager.add_potion_to_run(
		potion
	):

		return false

	remove_potion(
		potion
	)

	print(
		"Potion moved into run pocket:",
		potion.potion_name
	)

	return true


func get_potion_count(
	potion: PotionResource
) -> int:

	if potion == null:
		return 0

	return stored_potions.get(
		potion,
		0
	)

func remove_potion(
	potion: PotionResource,
	amount: int = 1
) -> bool:

	if potion == null:
		return false

	if amount <= 0:
		return false

	var current := get_potion_count(
		potion
	)

	if current < amount:
		return false

	current -= amount

	if current <= 0:
		stored_potions.erase(potion)
	else:
		stored_potions[potion] = current

	return true


func return_potion_from_run(
	potion: PotionResource,
	run_manager: RunManager
) -> bool:

	if potion == null:
		return false

	if run_manager == null:
		return false

	add_potion(
		potion
	)

	print(
		"Potion returned to storage:",
		potion.potion_name
	)

	return true
