extends PassiveEffect
class_name BloodlustPassive

@export var attack_gain := 1

func on_after_attack(owner, target, damage):

	owner.modify_attack(attack_gain)

	print(owner.name, " gains attack.")
