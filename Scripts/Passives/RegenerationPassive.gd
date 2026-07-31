extends PassiveEffect
class_name RegenerationPassive

@export var heal_amount := 3

func on_turn_end(owner):

	owner.heal(heal_amount)

	print(
		owner.name,
		" regenerated ",
		heal_amount,
		" HP"
	)
