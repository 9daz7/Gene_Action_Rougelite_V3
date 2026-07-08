extends Node
class_name DamageCalculator

static func calculate_damage(attacker, defender,move) -> int:
	
	var damage = 0
	
	# base damage
	damage = attacker.get_attack() + move.power
	
	print("Base damage:", damage)
	
	# apply attacker bonuses
	damage = apply_attack_modifiers(
		attacker,
		defender,
		move,
		damage
	)

	# prevent negative damage
	damage = max(damage, 0)
	
	return damage
	
static func apply_attack_modifiers(attacker, defender, move, damage):
	
	# future:
	# - critical hits
	# - damage buffs
	# - gene bonuses
	
	for passive in attacker.passive_effects:
		
		damage = passive.ov_before_attack(
			attacker,
			defender,
			damage
		)
		
	return damage
	
static func apply_defense_modifiers(defender, damage):
	
	# protect blocks 80%
	if defender.is_protecting:
		damage *= (1.0 - defender.protect_reduction)
		
		print(
			defender.name,
			" protected damage reduced to ",
			damage
		)
		
	# future:
	# - armor
	# - dodge
	
	for passive in defender.passive_effects:
		
		damage = passive.on_before_damage(
			defender,
			damage
		)
	
	return int(damage)
