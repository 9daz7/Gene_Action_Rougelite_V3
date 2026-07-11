extends Node
class_name DamageCalculator


static func calculate_damage(attacker, defender, move) -> int:
	var damage = 0

	# Base damage
	damage = attacker.get_attack() + move.power

	print("Base damage:", damage)

	# Apply attacker bonuses
	damage = apply_attack_modifiers(
		attacker,
		defender,
		move,
		damage
	)

	# Prevent negative damage
	damage = max(damage, 0)

	return damage


static func apply_attack_modifiers(attacker, defender, move, damage):
	# Future:
	# - Critical hits
	# - Damage buffs
	# - Gene bonuses

	for passive in attacker.passive_effects:
		damage = passive.ov_before_attack(
			attacker,
			defender,
			damage
		)

	return damage


static func apply_defense_modifiers(defender, damage):
	# Protect blocks 80%
	if defender.is_protecting:
		damage *= (1.0 - defender.protect_reduction)

		print(
			defender.name,
			" protected damage reduced to ",
			damage
		)

	# Future:
	# - Armor
	# - Dodge

	for passive in defender.passive_effects:
		damage = passive.on_before_damage(
			defender,
			damage
		)

	return int(damage)
