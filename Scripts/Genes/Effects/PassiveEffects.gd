extends Resource
class_name PassiveEffect

# ==================================================
# Configuration
# ==================================================

@export var passive_id: String = ""
@export var effect_name: String = ""

@export_multiline var description: String = ""


# ==================================================
# Source Gene
# ==================================================

var source_gene: GeneResource


func initialize(gene: GeneResource):

	source_gene = gene


# ==================================================
# Battle
# ==================================================

# Battle starts
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
func on_before_attack(owner, data: Dictionary):
	pass

# After owner attacks
func on_after_attack(owner, data: Dictionary):
	pass

# After attack misses
func on_attack_missed(owner, data: Dictionary):
	pass


# ==================================================
# Critical Hits
# ==================================================

func on_critical_hit(owner, data: Dictionary):
	pass

func modify_critical_chance(owner, chance: int) -> int:
	return chance


# ==================================================
# Damage
# ==================================================

# Before taking damage
func on_before_damage(owner, data: Dictionary):
	pass

# After taking damage
func on_after_damage(owner, data: Dictionary):
	pass

func modify_damage_dealt(owner, damage: int) -> int:
	return damage

func modify_damage_taken(owner, damage: int) -> int:
	return damage


# ==================================================
# Status Effects
# ==================================================


# Status applied to owner
func on_apply_status(owner, data: Dictionary):
	pass

# Status received by owner
func on_status_received(owner, data: Dictionary):
	pass

# Status removed from owner
func on_remove_status(owner, data: Dictionary):
	pass


# ==================================================
# Stats
# ==================================================


func modify_max_hp(owner, hp: int) -> int:
	return hp

func modify_attack(owner, attack: int) -> int:
	return attack

func modify_speed(owner, speed: int) -> int:
	return speed

func modify_accuracy(owner, accuracy: int) -> int:
	return accuracy

func modify_armor(owner, armor: int) -> int:
	return armor

func modify_evasion(owner, evasion: int) -> int:
	return evasion

#func get_critical_bonus(owner) -> int:
	#return 0

# ==================================================
# Healing
# ==================================================

func on_before_heal(owner, data: Dictionary):
	pass

func on_after_heal(owner, data: Dictionary):
	pass


# ==================================================
# Death
# ==================================================

func on_death(owner):
	pass


# ==================================================
# Kill Events
# ==================================================

func on_kill(owner, data: Dictionary):
	pass
