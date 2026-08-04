extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")

func get_all_enemies() -> Array:
	return turn_manager.enemies

func get_all_allies() -> Array:
	return [self]

func initialize_player(manager:RunManager):
	run_manager = manager


func take_damage(
	amount:int,
	attacker:AnimalBase = null,
	is_status_damage:bool = false
):

	super.take_damage(
		amount,
		attacker
	)

	if run_manager:
		run_manager.player_hp = hp


func get_display_name() -> String:
	return name
