extends PassiveEffect
class_name BerserkerPassive


@export var attack_bonus := 2

var activated := false

func on_turn_start(owner):

	if owner.hp <= owner.get_max_hp() * 0.5:

		if not activated:

			owner.modify_attack(
				attack_bonus
			)

			activated = true

			print(
				owner.name,
				" entered Berserker mode!"
			)
