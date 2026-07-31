extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")


func initialize_player(manager:RunManager):
	run_manager = manager


func take_damage(
	amount:int,
	attacker:AnimalBase = null
):

	super.take_damage(
		amount,
		attacker
	)

	if run_manager:
		run_manager.player_hp = hp


func get_display_name() -> String:
	return name
