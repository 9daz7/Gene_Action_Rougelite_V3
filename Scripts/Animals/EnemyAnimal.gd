extends AnimalBase
class_name EnemyAnimal


func start_battle():

	print("Enemy ready")
	
	setup_basic_moves()


func choose_action(_player):

	if learned_moves.size() > 0:
		return learned_moves[0]
		
	return null
		
