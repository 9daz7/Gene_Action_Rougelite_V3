extends AnimalBase
class_name PlayerAnimal

# ==================================================
# Battle
# ==================================================

func start_battle():
	print("Player ready")


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
	is_status_damage: bool = false,
	move: MoveResource = null
):

	super.take_damage(
		amount,
		attacker,
		is_status_damage,
		move
	)

	if run_manager:
		run_manager.player_hp = hp

# ==================================================
# Identity
# ==================================================

#func get_display_name() -> String:
	#return name
