extends PassiveEffect
class_name ThickSkinPassive

@export var damage_reduction := 0.20


func on_before_damage(owner, amount):

	var reduced_damage = amount * (1.0 - damage_reduction)

	print(
		owner.name,
		" Thick Hide reduced damage:",
		amount,
		"->",
		reduced_damage
	)

	return int(reduced_damage)
