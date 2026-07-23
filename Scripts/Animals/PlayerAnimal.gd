extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")
	
	
func initialize_player(manager:RunManager):
	run_manager = manager
	
	
func take_damage(amount:int):
	super.take_damage(amount)
	
	if run_manager:
		run_manager.player_hp = hp
