extends PassiveEffect
class_name AdrenalinePassive


@export var speed_bonus := 5


func on_after_damage(owner, amount):

	owner.modify_speed(speed_bonus)

	print(
		owner.name,
		" gains adrenaline. Speed +",
		speed_bonus
	)
