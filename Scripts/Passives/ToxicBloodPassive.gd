extends PassiveEffect
class_name ToxicBloodPassive

@export var poison: StatusEffect

func on_after_damage(owner, data: Dictionary):

	var amount: int = data.get(
		"amount",
		0
	)

	if amount <= 0:
		return

	var attacker: AnimalBase = data.get(
		"attacker"
	)

	if attacker == null:
		return

	if not is_instance_valid(attacker):
		return

	if poison == null:
		return

	attacker.apply_status_effect(
		poison
	)

	print(
		attacker.name,
		" was poisoned by ",
		owner.name,
		"'s Toxic Blood"
	)
