extends PassiveEffect
class_name LifestealPassive


@export var heal_percent := 0.2

func on_after_attack(
	owner,
	target,
	damage
):

	var heal_amount = int(
		damage * heal_percent
	)

	owner.heal(
		heal_amount
	)

	print(
		owner.name,
		" healed ",
		heal_amount
	)
