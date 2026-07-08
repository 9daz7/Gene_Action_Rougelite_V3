extends Resource
class_name PassiveEffect

@export var effect_name := ""
@export_multiline var description := ""

# battle starts
func on_battle_start(owner):
	pass
	
# turn starts
func on_turn_start(owner):
	pass
	
# turn ends
func on_turn_end(owner):
	pass
	
# before owner attacks
func on_before_attack(owner, target):
	pass

# After owner attacks
func on_after_attack(owner, target, damage):
	pass

# Before taking damage
func on_before_damage(owner, amount):
	return amount

# After taking damage
func on_after_damage(owner, amount):
	pass

# Battle ends
func on_battle_end(owner):
	pass
