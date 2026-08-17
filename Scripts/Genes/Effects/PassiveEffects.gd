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


func initialize(gene: GeneResource) -> void:

	source_gene = gene


# ==================================================
# Battle
# ==================================================

# Battle starts
func on_battle_start(
	owner: AnimalBase
) -> void:

	pass

# Battle ends
func on_battle_end(
	owner: AnimalBase
) -> void:

	pass


# ==================================================
# Turns
# ==================================================

# Turn starts
func on_turn_start(
	owner: AnimalBase
) -> void:

	pass

# Turn ends
func on_turn_end(
	owner: AnimalBase
) -> void:

	pass


# ==================================================
# Attacking
# ==================================================

# Before owner attacks
func on_before_attack(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

# After owner attacks
func on_after_attack(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

# After attack misses
func on_attack_missed(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass


# ==================================================
# Critical Hits
# ==================================================

func on_critical_hit(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

func modify_critical_chance(
	owner: AnimalBase,
	chance: int
) -> int:

	return chance


# ==================================================
# Damage
# ==================================================

# Before taking damage
func on_before_damage(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

# After taking damage
func on_after_damage(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

func modify_damage_dealt(
	owner: AnimalBase,
	damage: int
) -> int:

	return damage

func modify_damage_taken(
	owner: AnimalBase,
	damage: int
) -> int:

	return damage


# ==================================================
# Status Effects
# ==================================================


# Status applied to owner
func on_apply_status(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

# Status received by owner
func on_status_received(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

# Status removed from owner
func on_remove_status(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass


# ==================================================
# Stats
# ==================================================


func modify_max_hp(
	owner: AnimalBase,
	hp: int
) -> int:

	return hp

func modify_attack(
	owner: AnimalBase,
	attack: int
) -> int:

	return attack

func modify_speed(
	owner: AnimalBase,
	speed: int
) -> int:

	return speed

func modify_accuracy(
	owner: AnimalBase,
	accuracy: int
) -> int:

	return accuracy

func modify_armor(
	owner: AnimalBase,
	armor: int
) -> int:

	return armor

func modify_evasion(
	owner: AnimalBase,
	evasion: int
) -> int:

	return evasion


# ==================================================
# Healing
# ==================================================

func on_before_heal(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass

func on_after_heal(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass


# ==================================================
# Death
# ==================================================

func on_death(
	owner: AnimalBase
) -> void:

	pass


# ==================================================
# Kill Events
# ==================================================

func on_kill(
	owner: AnimalBase,
	data: Dictionary
) -> void:

	pass
