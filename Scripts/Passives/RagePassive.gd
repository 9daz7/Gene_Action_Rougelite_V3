extends PassiveEffect
class_name RagePassive


@export var attack_bonus := 2
@export var max_stacks := 3


var stacks := 0


func on_after_damage(owner, amount, attacker):

	if stacks >= max_stacks:
		return

	stacks += 1

	owner.modify_attack(
		attack_bonus
	)

	print(
		owner.name,
		" rage stack:",
		stacks,
		"+",
		attack_bonus,
		" attack"
	)
