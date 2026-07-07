extends AnimalBase
class_name EnemyAnimal


func start_battle():

	print("Enemy ready")


func choose_action(_player) -> String:

	if hp > get_max_hp() * 0.5:
		return "protect" if randf() < 0.3 else "attack"
	else:
		return "protect" if randf() < 0.5 else "attack"
		
		
func attack(player):
	var damage = get_attack()
	print("Enemy attacks for ", damage)
	player.take_damage(damage)
