extends Node
class_name MultiHitEffect


@export var hits:int = 2


func apply(user,target):

	for i in hits:

		var damage = user.get_attack()

		damage = target.calculate_damage_taken(
			damage
		)

		target.take_damage(damage)
