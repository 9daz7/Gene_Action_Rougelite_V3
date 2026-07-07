extends AnimalBase
class_name EnemyAnimal

# enemy ai logic 

func start_battle():

	hp = get_max_hp()

	print("Enemy battle started")


func choose_action(_player) -> String:

	if hp > get_max_hp() * 0.5:
		return "protect" if randf() < 0.3 else "attack"

	else:
		return "protect" if randf() < 0.5 else "attack"
