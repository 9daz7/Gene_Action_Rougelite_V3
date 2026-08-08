extends PassiveEffect
class_name BloodlustPassive

@export var attack_gain := 1

func on_after_attack(
	owner,
	data: Dictionary
):

	var target = data.get("target")
	var damage = data.get("damage", 0)

	owner.modify_attack(
		attack_gain
	)

	print(
		owner.name,
		" gains attack."
	)
