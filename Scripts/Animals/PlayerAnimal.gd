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

func initialize_player(manager: RunManager) -> void:

	print("================================")
	print("PLAYER ANIMAL INITIALIZE")
	print("RunManager:", manager)
	print("Current build:", manager.current_animal_build if manager else null)
	print("================================")

	run_manager = manager

	if run_manager == null:
		push_error("PlayerAnimal: RunManager is missing.")
		return

	if run_manager.current_animal_build == null:
		push_error("PlayerAnimal: Current animal build is missing.")
		return

	load_build(
		run_manager.current_animal_build
	)

	print("PLAYER BUILD LOADED")
	print("Animal:", animal_resource.animal_name if animal_resource else "NULL")
	print("Basic moves:", basic_moves)
	print("Selected moves:", selected_moves)
	print("Battle moves:", get_battle_moves())
	print("================================")


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
