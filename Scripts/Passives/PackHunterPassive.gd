extends PassiveEffect
class_name PackHunterPassive


@export var damage_bonus := 5


func on_before_attack(owner, data: Dictionary):

	var allies := owner.get_all_allies()

	var living_allies := 0

	for animal in allies:

		if animal == null:
			continue

		if not is_instance_valid(animal):
			continue

		if animal == owner:
			continue

		if animal.is_alive():
			living_allies += 1

	if living_allies > 0:
		return

		owner.modify_attack(damage_bonus)

		print(
			owner.name,
			" gains pack hunter bonus"
		)
