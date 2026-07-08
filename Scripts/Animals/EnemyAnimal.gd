extends AnimalBase
class_name EnemyAnimal


func start_battle():

	print("Enemy ready")
	
	setup_basic_moves()


func choose_action(_player) -> MoveResource:

	return get_move(0)
		
