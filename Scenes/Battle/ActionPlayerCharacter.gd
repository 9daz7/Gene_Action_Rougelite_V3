extends CharacterBody2D
class_name ActionPlayerCharacter


# ==================================================
# Health
# ==================================================

@export var max_health: float = 100.0

var health: float = 100.0


# ==================================================
# Signals
# ==================================================

signal health_changed(current_health: float, maximum_health: float)
signal died


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	health = max_health

	print(
		"ACTION PLAYER CHARACTER READY | HP: ",
		health,
		"/",
		max_health
	)


# ==================================================
# Health
# ==================================================

func take_damage(damage: float) -> void:

	if damage <= 0.0:
		return

	if not is_alive():
		return

	health = max(
		health - damage,
		0.0
	)

	print(
		"HUMAN TOOK ",
		damage,
		" DAMAGE | HP: ",
		health,
		"/",
		max_health
	)

	health_changed.emit(
		health,
		max_health
	)

	if health <= 0.0:

		_die()


func heal(amount: float) -> void:

	if amount <= 0.0:
		return

	if not is_alive():
		return

	health = min(
		health + amount,
		max_health
	)

	print(
		"PLAYER CHARACTER HEALED ",
		amount,
		" | HP: ",
		health,
		"/",
		max_health
	)

	health_changed.emit(
		health,
		max_health
	)


func is_alive() -> bool:

	return health > 0.0

func _die() -> void:

	print(
		"PLAYER CHARCTER HAS BEEN DETECTED"
	)

	died.emit()
