extends PassiveEffect
class_name ThornsPassive


@export var reflect_damage := 5


func on_after_damage(owner, amount):

	print(
		owner.name,
		" reflects ",
		reflect_damage,
		" damage"
	)
