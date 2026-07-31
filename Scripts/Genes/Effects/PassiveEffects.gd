extends Resource
class_name PassiveEffect

@export var effect_name := ""
@export_multiline var description := ""


# ==================================================
# Battle
# ==================================================

func on_battle_start(owner):
	pass

# Battle ends
func on_battle_end(owner):
	pass


# ==================================================
# Turns
# ==================================================

# Turn starts
func on_turn_start(owner):
	pass

# Turn ends
func on_turn_end(owner):
	pass


# ==================================================
# Attacking
# ==================================================

# Before owner attacks
func on_before_attack(owner, target):
	pass


# After owner attacks
func on_after_attack(owner, target, damage):
	pass


# ==================================================
# Damage
# ==================================================

# Before taking damage
func on_before_damage(owner, amount):
	return amount


# After taking damage
func on_after_damage(owner, amount, attacker):
	pass


# ==================================================
# Status Effects
# ==================================================

func on_apply_status(owner, status):
	pass

func on_remove_status(owner, status):
	pass


# ==================================================
# Healing
# ==================================================

func on_before_heal(owner, amount):
	return amount

func on_after_heal(owner, amount):
	pass


# ==================================================
# Death
# ==================================================

func on_death(owner):
	pass
