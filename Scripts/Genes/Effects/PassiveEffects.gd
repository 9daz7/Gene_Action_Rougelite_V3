extends Resource
class_name PassiveEffect

@export var passive_id:String = ""
@export var effect_name := ""
@export_multiline var description := ""

var source_gene: GeneResource


func initialize(gene:GeneResource):

	source_gene = gene


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

func on_attack_missed(owner, target):
	pass


# ==================================================
# Critical Hits
# ==================================================

func on_critical_hit(owner, target, damage):
	pass

func modify_critical_chance(owner, chance):
	return chance


# ==================================================
# Damage
# ==================================================

# Before taking damage
func on_before_damage(owner, amount):
	return amount

# After taking damage
func on_after_damage(owner, amount, attacker):
	pass

func modify_damage_dealt(owner, damage):
	return damage

func modify_damage_taken(owner, damage):
	return damage


# ==================================================
# Status Effects
# ==================================================

func on_apply_status(owner, status):
	pass

func on_remove_status(owner, status):
	pass


# ==================================================
# Stats
# ==================================================

func modify_max_hp(owner, hp):
	return hp

func modify_attack(owner, attack):
	return attack

func modify_speed(owner, speed):
	return speed

func modify_accuracy(owner, accuracy):
	return accuracy

func modify_armor(owner, armor):
	return armor

func modify_evasion(owner, evasion):
	return evasion

func get_critical_bonus(owner):
	return 0

# ==================================================
# Healing
# ==================================================

func on_before_heal(owner, amount):
	return amount

func on_after_heal(owner, amount):
	pass

func on_heal(owner, amount):
	pass


# ==================================================
# Death
# ==================================================

func on_death(owner):
	pass


# ==================================================
# Kill Events
# ==================================================

func on_kill(owner, target):
	pass
