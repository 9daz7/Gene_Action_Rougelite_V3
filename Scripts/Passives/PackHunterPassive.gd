extends PassiveEffect
class_name PackHunterPassive


@export var damage_bonus := 5


func on_before_attack(owner,target):

	var allies = 0


	for animal in get_tree().get_nodes_in_group("animals"):

		if animal != owner and animal.is_alive():
			allies += 1


	if allies > 0:

		owner.modify_attack(damage_bonus)

		print(
			owner.name,
			" gains pack hunter bonus"
		)
