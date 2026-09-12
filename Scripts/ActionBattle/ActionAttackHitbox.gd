extends Area2D
class_name ActionAttackHitbox


# ==================================================
# Detection
# ==================================================

var detected_enemies: Array[AnimalBase] = []


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("ActionAttackHitbox ready")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ==================================================
# Enemy Detection
# ==================================================

func _on_body_entered(body: Node2D) -> void:

	if not body is AnimalBase:
		return

	var enemy := body as AnimalBase

	if not enemy.is_alive():
		return

	if enemy in detected_enemies:
		return

	detected_enemies.append(enemy)

	print(
		"ACTION HITBOX ENTERED: ",
		enemy.name
	)


func _on_body_exited(body: Node2D) -> void:

	if not body is AnimalBase:
		return

	var enemy := body as AnimalBase

	if enemy in detected_enemies:
		detected_enemies.erase(enemy)

	print(
		"ACTION HITBOX EXITED: ",
		enemy.name
	)


# ==================================================
# Public Access
# ==================================================

func get_detected_enemies() -> Array[AnimalBase]:

	for enemy in detected_enemies.duplicate():

		if not is_instance_valid(enemy):
			detected_enemies.erase(enemy)
			continue

		if not enemy.is_alive():
			detected_enemies.erase(enemy)

	return detected_enemies
