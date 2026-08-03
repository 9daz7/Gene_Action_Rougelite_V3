extends PassiveEffect
class_name ArmorPassive


@export var damage_reduction := 0.2


func modify_damage_taken(owner, damage):

	var reduced = damage * (1.0 - damage_reduction)

	print(
		owner.name,
		" reduced damage by turtle shell"
	)

	return int(damage)
