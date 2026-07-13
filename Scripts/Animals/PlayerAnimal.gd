extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")
	
	setup_basic_moves()
	
	
func setup_player_hp(run_manager):
	max_hp = run_manager.max_hp
	hp = run_manager.player_hp

	print(
		"Loaded player HP:",
		hp,
		"/",
		max_hp
	)
