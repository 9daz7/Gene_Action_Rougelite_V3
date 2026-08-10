extends PassiveEffect
class_name AdrenalinePassive


@export var speed_bonus := 5


func on_after_damage(owner, data: Dictionary):

	var amount: int = data.get(
		"amount",
		0
	)

	if amount <= 0:
		return

	owner.modify_speed(speed_bonus)

	print(
		owner.name,
		" gains adrenaline. Speed +",
		speed_bonus
	)
