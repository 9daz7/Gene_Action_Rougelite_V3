extends PassiveEffect
class_name RegenerationPassive

@export var heal_amount := 5

func on_turn_start(owner):

	print(
		owner.name,
		" regenerates ",
		heal_amount,
		" HP"
	)

	owner.heal(
		heal_amount
	)
