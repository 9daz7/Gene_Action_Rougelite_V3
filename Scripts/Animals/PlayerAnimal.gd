extends AnimalBase
class_name PlayerAnimal

# ==================================================
# Battle
# ==================================================

func start_battle():
	print("Player ready")

# ==================================================
# Targeting
# ==================================================

func get_opponents() -> Array:
	if turn_manager == null:
		return []

	return turn_manager.enemies

func get_team_members() -> Array:
	return [self]
	
# ==================================================
# Initialization
# ==================================================

func initialize_player(manager:RunManager):
	run_manager = manager

# ==================================================
# Combat
# ==================================================

func take_damage(
	amount:int,
	attacker:AnimalBase = null,
	is_status_damage:bool = false
):

	super.take_damage(
		amount,
		attacker,
		is_status_damage
	)

	if run_manager:
		run_manager.player_hp = hp

# ==================================================
# Identity
# ==================================================

func get_display_name() -> String:
	return name
