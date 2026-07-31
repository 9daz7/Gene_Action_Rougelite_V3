extends PassiveEffect
class_name ToxicBloodPassive

@export var poison: StatusEffect

func on_after_damage(owner, amount):

	if amount > 0:
		poison.apply(owner)
