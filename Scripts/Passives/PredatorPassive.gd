extends PassiveEffect
class_name PredatorPassive


@export var damage_bonus := 10
@export var target_threshold := 0.3


func on_after_attack(
	owner,
	data: Dictionary
):

	var target: AnimalBase = data.get("target")

	if target == null:
		return

	var hp_percent := (
		float(target.hp)
		/ float(target.get_max_hp())
	)

	if hp_percent <= target_threshold:

		target.take_damage(
			damage_bonus,
			owner
		)

		print(
			owner.name,
			" predator bonus damage ",
			damage_bonus
		)
