extends Resource
class_name StatusEffect


enum Type
{
	POISON,
	BLEED,
	BURN,
	HEAL,
	SPEED_UP,
	SPEED_DOWN,
	ATTACK_UP,
	ATTACK_DOWN,
	DEFENSE_UP,
	DEFENSE_DOWN
}

@export var effect_name:String
@export var type:Type
@export var power:int = 5
@export var duration:int = 3
@export var stat_modifier := ""

@export var can_stack := true
@export var max_stacks := 3
@export var refresh_duration := true
@export var stack_power := true

var stacks := 1


func get_display_text() -> String:

	if stacks > 1:
		return effect_name + " x" + str(stacks) + " (" + str(duration) + ")"

	return effect_name + " (" + str(duration) + ")"


func apply(target):

	if type == Type.HEAL:
		target.heal(power)
		return

	#var new_effect = duplicate()
#
	#target.status_effects.append(new_effect)

	print(
		effect_name,
		" applied to ",
		target.name
	)

	match type:

		Type.SPEED_UP:
			target.modify_speed(get_total_power())

			print(
				target.name,
				" speed increased by ",
				get_total_power()
			)

		Type.SPEED_DOWN:
			target.modify_speed(-get_total_power())

			print(
				target.name,
				" speed decreased by ",
				get_total_power()
			)

		Type.ATTACK_UP:
			target.modify_attack(get_total_power())

			print(
				target.name,
				" attack increased by ",
				get_total_power()
			)

		Type.ATTACK_DOWN:
			target.modify_attack(-get_total_power())

			print(
				target.name,
				" sttack decreased by ",
				get_total_power()
			)

		Type.DEFENSE_UP:
			target.modify_defense(get_total_power())

			print(
				target.name,
				" defense increased by ",
				get_total_power()
			)

		Type.DEFENSE_DOWN:
			target.modify_defense(-get_total_power())

			print(
				target.name,
				" defense decreased by ",
				get_total_power()
			)


func remove(target):

	match type:

		Type.SPEED_UP:
			target.modify_speed(-get_total_power())

		Type.SPEED_DOWN:
			target.modify_speed(get_total_power())

		Type.ATTACK_UP:
			target.modify_attack(-get_total_power())

		Type.ATTACK_DOWN:
			target.modify_attack(get_total_power())

		Type.DEFENSE_UP:
			target.modify_defense(-get_total_power())

		Type.DEFENSE_DOWN:
			target.modify_defense(get_total_power())


	print(
		effect_name,
		" removed from ",
		target.name
	)


func get_total_power() -> int:

	if stack_power:
		return power * stacks

	return power


func apply_stack(target, amount:int):

	var stack_amount = power * amount

	match type:

		Type.SPEED_UP:
			target.modify_speed(stack_amount)

		Type.SPEED_DOWN:
			target.modify_speed(-stack_amount)

		Type.ATTACK_UP:
			target.modify_attack(stack_amount)

		Type.ATTACK_DOWN:
			target.modify_attack(-stack_amount)

		Type.DEFENSE_UP:
			target.modify_defense(stack_amount)

		Type.DEFENSE_DOWN:
			target.modify_defense(-stack_amount)
