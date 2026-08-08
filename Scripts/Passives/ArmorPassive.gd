extends PassiveEffect
class_name ArmorPassive


@export var damage_reduction := 0.8


func modify_damage_taken(
	owner,
	damage: int
) -> int:

	var reduced := damage * (
		1.0 - damage_reduction
	)

	print(
		owner.name,
		" reduced damage with Turtle Shell:",
		damage,
		"->",
		reduced
	)

	return int(reduced)
