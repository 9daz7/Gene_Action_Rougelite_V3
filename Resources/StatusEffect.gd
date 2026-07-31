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


func get_display_text() -> String:

	return effect_name + " (" + str(duration) + ")"


func apply(target):

	if type == Type.HEAL:

		target.heal(power)
		return

	var new_effect = duplicate()

	target.status_effects.append(new_effect)

	print(
		effect_name,
		" applied to ",
		target.name
	)

	match type:

		Type.SPEED_UP:
			target.modify_speed(power)

			print(
				target.name,
				" speed increased by ",
				power
			)

		Type.SPEED_DOWN:
			target.modify_speed(-power)

			print(
				target.name,
				" speed decreased by ",
				power
			)

		Type.ATTACK_UP:
			target.modify_attack(power)

			print(
				target.name,
				" attack increased by ",
				power
			)

		Type.ATTACK_DOWN:
			target.modify_attack(-power)

			print(
				target.name,
				" sttack decreased by ",
				power
			)

		Type.DEFENSE_UP:
			target.modify_defense(power)

			print(
				target.name,
				" defense increased by ",
				power
			)

		Type.DEFENSE_DOWN:
			target.modify_defense(-power)

			print(
				target.name,
				" defense decreased by ",
				power
			)


func remove(target):

	match type:

		Type.SPEED_UP:
			target.modify_speed(-power)

		Type.SPEED_DOWN:
			target.modify_speed(power)

		Type.ATTACK_UP:
			target.modify_attack(-power)

		Type.ATTACK_DOWN:
			target.modify_attack(power)

		Type.DEFENSE_UP:
			target.modify_defense(-power)

		Type.DEFENSE_DOWN:
			target.modify_defense(power)


	print(
		effect_name,
		" removed from ",
		target.name
	)
