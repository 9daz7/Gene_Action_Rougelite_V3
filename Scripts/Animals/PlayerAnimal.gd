extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")
	
	setup_basic_moves()
	
	
func setup_player_hp(manager):
	
	run_manager = manager
	
	base_hp = run_manager.max_hp
	hp = run_manager.player_hp

	print(
		"Loaded player HP:",
		hp,
		"/",
		base_hp
	)

func take_damage(amount:int):
	super.take_damage(amount)
	if run_manager:
		run_manager.player_hp = hp

		print(
			"Saved run HP:",
			run_manager.player_hp
		)
