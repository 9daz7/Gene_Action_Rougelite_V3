extends AnimalBase
class_name EnemyAnimal


func start_battle():

	print("Enemy ready")
	
	setup_basic_moves()


func choose_action(_player) -> String:

	return "attack"
		
func attack(player):
	
	use_move(0, player)
