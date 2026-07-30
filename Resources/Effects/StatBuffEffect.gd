extends Node
class_name StatBuffEffect


enum StatType
{
	ATTACK,
	SPEED,
	DEFENSE
}


@export var stat:StatType
@export var amount:int = 1


func apply(user,target):

	match stat:

		StatType.ATTACK:
			user.modify_attack(amount)


		StatType.SPEED:
			user.modify_speed(amount)


		StatType.DEFENSE:
			user.modify_defense(amount)
