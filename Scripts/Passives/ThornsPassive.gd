extends PassiveEffect
class_name ThornsPassive


@export var reflect_damage := 5


func on_after_damage(owner, data: Dictionary):

	var attacker: AnimalBase = data.get(
		"attacker"
	)

	var amount: int = data.get(
		"amount",
		0
	)

	if attacker == null:
		return

	if not is_instance_valid(attacker):
		return

	if not attacker.is_alive():
		return

	if amount <= 0:
		return

	print(
		owner.name,
		" reflects ",
		reflect_damage,
		" damage"
	)

	attacker.take_damage(
		reflect_damage,
		owner
	)
