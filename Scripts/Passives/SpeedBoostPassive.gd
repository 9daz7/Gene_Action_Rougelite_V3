extends PassiveEffect
class_name SpeedBoostPassive


@export var speed_bonus := 3

func on_battle_start(owner):

	owner.modify_speed(
		speed_bonus
	)

	print(
		owner.name,
		" gained speed:",
		speed_bonus
	)
