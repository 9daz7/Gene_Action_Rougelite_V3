extends PassiveEffect
class_name ThickSkinPassive

@export var reduction := 2

func on_before_damage(owner, amount):

	return max(1, amount - reduction)
