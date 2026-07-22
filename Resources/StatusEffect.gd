extends Resource
class_name StatusEffect


enum Type
{
	POISON,
	BLEED,
	BURN,
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


func get_display_text():

	return effect_name + " (" + str(duration) + ")"
	
	
func apply(target):
	
	var new_effect = duplicate()
	
	target.status_effects.append(new_effect)

	print(
		effect_name,
		" applied to ",
		target.name
	)

	match type:

		Type.SPEED_UP:
			target.speed_modifier += power

			print(
				target.name,
				" speed increased by ",
				power
			)

		Type.SPEED_DOWN:
			target.speed_modifier -= power
			
			print(
				target.name,
				" speed -",
				power
			)

		Type.ATTACK_UP:
			target.attack_modifier += power

		Type.ATTACK_DOWN:
			target.attack_modifier -= power

		Type.DEFENSE_UP:
			target.defense_modifier += power

		Type.DEFENSE_DOWN:
			target.defense_modifier -= power
			
			
func remove(target):

	match type:

		Type.SPEED_UP:
			target.speed_modifier -= power

		Type.SPEED_DOWN:
			target.speed_modifier += power

		Type.ATTACK_UP:
			target.attack_modifier -= power

		Type.ATTACK_DOWN:
			target.attack_modifier += power

		Type.DEFENSE_UP:
			target.defense_modifier -= power

		Type.DEFENSE_DOWN:
			target.defense_modifier += power


	print(
		effect_name,
		" removed from ",
		target.name
	)
