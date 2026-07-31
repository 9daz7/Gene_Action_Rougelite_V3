extends PassiveEffect
class_name RagePassive


@export var attack_bonus := 5
@export var health_threshold := 0.5


func on_turn_start(owner):

	var hp_percent = float(owner.hp) / float(owner.get_max_hp())

	if hp_percent <= health_threshold:

		owner.modify_attack(attack_bonus)

		print(
			owner.name,
			" enters rage. Attack +",
			attack_bonus
		)
