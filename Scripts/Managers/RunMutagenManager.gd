extends Node
class_name RunMutagenManager


@onready var mutagen_database: MutagenDatabase = get_node(
	"../MutagenDatabase"
)


@onready var run_manager: RunManager = get_node(
	"../RunManager"
)

# ==================================================
# Settings
# ==================================================

const MAX_EQUIPPED_MUTAGENS: int = 6
const MAX_RESERVE_MUTAGENS: int = 1


# ==================================================
# Mutagen Family Weights
# ==================================================

const BASE_FAMILY_WEIGHT: float = 10.0
const FAMILY_SYNERGY_WEIGHT: float = 5.0


# ==================================================
# Equipped Mutagens
# ==================================================

var equipped_mutagens: Array[MutagenResource] = []


# ==================================================
# Reserve Mutagen
# ==================================================

var reserve_mutagen: MutagenResource = null


# ==================================================
# Signals
# ==================================================

signal mutagens_changed
signal mutagen_added(mutagen)
signal mutagen_removed(mutagen)
signal mutagen_replaced(old_mutagen, new_mutagen)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("RUN MUTAGEN MANAGER READY")


func get_family_weight(
	family: MutagenResource.MutagenFamily
) -> float:

	var weight: float = BASE_FAMILY_WEIGHT

	for mutagen in equipped_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_family == family:

			weight += FAMILY_SYNERGY_WEIGHT

		for tag in mutagen.tags:

			var affinity: float = _family_tag_affinity(
				family,
				tag
			)

			weight += FAMILY_SYNERGY_WEIGHT * affinity

	return weight


func _family_tag_affinity(
	family: MutagenResource.MutagenFamily,
	tag: MutagenResource.MutagenTag
) -> float:

	match family:

		MutagenResource.MutagenFamily.FERAL:

			match tag:
				MutagenResource.MutagenTag.ATTACK:
					return 1.0

				MutagenResource.MutagenTag.BLEED:
					return 1.0

				MutagenResource.MutagenTag.CRITICAL:
					return 0.5

				_:
					return 0.0

		MutagenResource.MutagenFamily.INFERNO:

			match tag:
				MutagenResource.MutagenTag.FIRE:
					return 1.0

				MutagenResource.MutagenTag.BURN:
					return 1.0

				MutagenResource.MutagenTag.ATTACK:
					return 0.5

				_:
					return 0.0

		MutagenResource.MutagenFamily.STORM:

			match tag:
				MutagenResource.MutagenTag.ELECTRIC:
					return 1.0

				MutagenResource.MutagenTag.STATIC:
					return 1.0

				MutagenResource.MutagenTag.SPEED:
					return 0.75

				MutagenResource.MutagenTag.SHOCK:
					return 0.5

				_:
					return 0.0

		MutagenResource.MutagenFamily.VENOM:

			match tag:
				MutagenResource.MutagenTag.POISON:
					return 1.0

				MutagenResource.MutagenTag.SHOCK:
					return 0.25

				MutagenResource.MutagenTag.EVASION:
					return 0.5

				_:
					return 0.0

		MutagenResource.MutagenFamily.PREDATOR:

			match tag:
				MutagenResource.MutagenTag.CRITICAL:
					return 1.0

				MutagenResource.MutagenTag.EXECUTE:
					return 1.0

				MutagenResource.MutagenTag.ATTACK:
					return 0.5

				MutagenResource.MutagenTag.BLEED:
					return 0.25

				_:
					return 0.0

		MutagenResource.MutagenFamily.CARAPACE:

			match tag:
				MutagenResource.MutagenTag.DEFENSE:
					return 1.0

				MutagenResource.MutagenTag.THORNS:
					return 1.0

				MutagenResource.MutagenTag.HP:
					return 0.5

				_:
					return 0.0

		MutagenResource.MutagenFamily.VITALITY:

			match tag:
				MutagenResource.MutagenTag.HP:
					return 1.0

				MutagenResource.MutagenTag.HEALING:
					return 1.0

				MutagenResource.MutagenTag.REGENERATION:
					return 1.0

				MutagenResource.MutagenTag.DEFENSE:
					return 0.25

				_:
					return 0.0

		MutagenResource.MutagenFamily.INSTINCT:

			match tag:
				MutagenResource.MutagenTag.SPEED:
					return 1.0

				MutagenResource.MutagenTag.EVASION:
					return 1.0

				MutagenResource.MutagenTag.CRITICAL:
					return 0.25

				_:
					return 0.0

		MutagenResource.MutagenFamily.SCAVENGER:

			match tag:
				MutagenResource.MutagenTag.REWARDS:
					return 1.0

				MutagenResource.MutagenTag.GOLD:
					return 1.0

				_:
					return 0.0

		_:
			return 0.0


# ==================================================
# Add Mutagen
# ==================================================

func add_mutagen(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:

		push_error(
			"RunMutagenManager: Cannot add null Mutagen."
		)

		return false

	# ==================================================
	# Add directly if there is an open equipped slot.
	# ==================================================

	if equipped_mutagens.size() < MAX_EQUIPPED_MUTAGENS:

		equipped_mutagens.append(
			mutagen
		)

		print(
			"MUTAGEN EQUIPPED:",
			mutagen.mutagen_name
		)

		mutagen_added.emit(
			mutagen
		)

		mutagens_changed.emit()

		return true

	# ==================================================
	# Equipped slots are full.
	# ==================================================

	print(
		"Mutagen slots full:",
		mutagen.mutagen_name
	)

	return false


# ==================================================
# Add Mutagen With Reserve Handling
# ==================================================

func add_mutagen_with_reserve(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:

		push_error(
			"RunMutagenManager: Cannot add null Mutagen."
		)

		return false

	# ==================================================
	# Equipped Slot Available
	# ==================================================

	if equipped_mutagens.size() < MAX_EQUIPPED_MUTAGENS:

		return add_mutagen(
			mutagen
		)

	# ==================================================
	# Equipped Full / Reserve Available
	# ==================================================

	if reserve_mutagen == null:

		if set_reserve_mutagen(
			mutagen
		):

			print(
				"MUTAGEN MOVED TO RESERVE:",
				mutagen.mutagen_name
			)

			return true

		return false

	# ==================================================
	# Equipped + Reserve Full
	# ==================================================

	print(
		"Mutagen slots and reserve are full:",
		mutagen.mutagen_name
	)

	return false


func add_critical_lab_reward() -> MutagenResource:

	if mutagen_database == null:

		push_error(
			"RunMutagenManager: MutagenDatabase is missing."
		)

		return null

	if run_manager == null:

		push_error(
			"RunMutagenManager: RunManager is missing."
		)

		return null

	var current_world: int = (
		run_manager.current_world
	)

	var candidates: Array[MutagenResource] = []

	# ==================================================
	# Find Critical Lab Mutagens
	# ==================================================

	for mutagen in mutagen_database.get_mutagens_for_world(
		current_world
	):

		if mutagen == null:
			continue

		if not mutagen.critical_lab_exclusive:
			continue

		if not is_mutagen_eligible(
			mutagen
		):

			continue

		candidates.append(
			mutagen
		)


	# ==================================================
	# No Eligible Critical Mutagens
	# ==================================================

	if candidates.is_empty():

		print(
			"RunMutagenManager: No eligible Critical Lab Mutagen for World ",
			current_world
		)

		return null


	# ==================================================
	# Select Reward
	# ==================================================

	candidates.shuffle()

	var reward: MutagenResource = candidates[0]

	print(
		"================================"
	)

	print(
		"CRITICAL LAB REWARD"
	)

	print(
		"World:",
		current_world
	)

	print(
		"Mutagen:",
		reward.mutagen_name
	)

	print(
		"Tier:",
		reward.tier
	)

	print(
		"================================"
	)

	return reward

	# ==================================================
	# Equip Reward
	# ==================================================

	#if equipped_mutagens.size() < MAX_EQUIPPED_MUTAGENS:
#
		#if add_mutagen(reward):
#
			#return reward
#
		#return null

	# ==================================================
	# Equipped Full → Reserve
	# ==================================================

	#if reserve_mutagen == null:
#
		#if set_reserve_mutagen(
			#reward
		#):
#
			#return reward
#
		#return null

	# ==================================================
	# No Available Storage
	# ==================================================

	#print(
		#"CRITICAL LAB REWARD CANNOT BE STORED:"
	#)
#
	#print(
		#reward.mutagen_name
	#)
#
	#print(
		#"Equipped slots and reserve are full."
	#)
#
	#return null


# ==================================================
# Set Reserve
# ==================================================

func set_reserve_mutagen(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:

		push_error(
			"RunMutagenManager: Cannot reserve null Mutagen."
		)

		return false

	if reserve_mutagen != null:

		print(
			"Reserve slot already occupied:",
			reserve_mutagen.mutagen_name
		)

		return false


	reserve_mutagen = mutagen

	print(
		"MUTAGEN RESERVED:",
		mutagen.mutagen_name
	)

	mutagens_changed.emit()

	return true


# ==================================================
# Remove Equipped Mutagen
# ==================================================

func remove_mutagen(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if not equipped_mutagens.has(
		mutagen
	):

		return false

	equipped_mutagens.erase(
		mutagen
	)

	print(
		"MUTAGEN REMOVED:",
		mutagen.mutagen_name
	)

	mutagen_removed.emit(
		mutagen
	)

	mutagens_changed.emit()

	return true


# ==================================================
# Remove Reserve Mutagen
# ==================================================

func remove_reserve_mutagen() -> MutagenResource:

	if reserve_mutagen == null:
		return null

	var removed: MutagenResource = reserve_mutagen

	reserve_mutagen = null

	print(
		"RESERVE MUTAGEN REMOVED:",
		removed.mutagen_name
	)

	mutagens_changed.emit()

	return removed


# ==================================================
# Replace Reserve Mutagen
# ==================================================

func replace_reserve_mutagen(
	new_mutagen: MutagenResource
) -> MutagenResource:

	if new_mutagen == null:

		push_error(
			"RunMutagenManager: Cannot replace reserve with null Mutagen."
		)

		return null

	var old_reserve: MutagenResource = reserve_mutagen

	reserve_mutagen = new_mutagen

	print(
		"RESERVE MUTAGEN REPLACED:",
		"Old:",
		old_reserve.mutagen_name if old_reserve != null else "Empty",
		"-> New:",
		new_mutagen.mutagen_name
	)

	mutagens_changed.emit()

	return old_reserve


# ==================================================
# Replace Equipped Mutagen
# ==================================================

func replace_mutagen(
	old_mutagen: MutagenResource,
	new_mutagen: MutagenResource
) -> bool:

	if old_mutagen == null:
		return false

	if new_mutagen == null:
		return false

	var index := equipped_mutagens.find(
		old_mutagen
	)

	if index == -1:
		return false

	equipped_mutagens[index] = new_mutagen

	print(
		"MUTAGEN REPLACED:",
		old_mutagen.mutagen_name,
		"->",
		new_mutagen.mutagen_name
	)

	mutagen_replaced.emit(
		old_mutagen,
		new_mutagen
	)

	mutagens_changed.emit()

	return true


# ==================================================
# Equip Reserve Mutagen
# ==================================================

func equip_reserve_mutagen(
	slot_index: int
) -> bool:

	if reserve_mutagen == null:

		print(
			"No reserve Mutagen available."
		)

		return false

	if slot_index < 0:

		return false

	if slot_index >= MAX_EQUIPPED_MUTAGENS:

		return false

	# ==================================================
	# Empty equipped slot
	# ==================================================

	if slot_index >= equipped_mutagens.size():

		var old_reserve: MutagenResource = (
			reserve_mutagen
		)

		equipped_mutagens.append(
			old_reserve
		)

		reserve_mutagen = null

		mutagens_changed.emit()

		print(
			"Reserve Mutagen equipped:",
			old_reserve.mutagen_name
		)

		return true

	# ==================================================
	# Swap with equipped slot.
	# ==================================================

	var equipped_mutagen: MutagenResource = (
		equipped_mutagens[slot_index]
	)

	equipped_mutagens[slot_index] = (
		reserve_mutagen
	)

	reserve_mutagen = equipped_mutagen

	print(
		"Reserve Mutagen swapped with:",
		equipped_mutagen.mutagen_name
	)

	mutagens_changed.emit()

	return true


# ==================================================
# Queries
# ==================================================

func has_mutagen(
	mutagen: MutagenResource
) -> bool:


	if mutagen == null:
		return false

	return equipped_mutagens.has(
		mutagen
	)


func is_full() -> bool:

	return (
		equipped_mutagens.size()
		>= MAX_EQUIPPED_MUTAGENS
	)


func has_reserve() -> bool:

	return reserve_mutagen != null


func get_equipped_mutagens() -> Array[MutagenResource]:

	return equipped_mutagens


func get_mutagens_by_family(
	family: MutagenResource.MutagenFamily
) -> Array[MutagenResource]:

	if mutagen_database == null:

		push_error(
			"RunMutagenManager: MutagenDatabase is missing."
		)

		return []

	if run_manager == null:

		push_error(
			"RunMutagenManager: RunManager is missing."
		)

		return []

	return mutagen_database.get_mutagens_by_family(
		family,
		run_manager.current_world
	)


func has_mutagen_type(
	required_type: MutagenResource.MutagenType
) -> bool:

	for mutagen in equipped_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_type == required_type:
			return true

	return false


func has_mutagen_family(
	required_family: MutagenResource.MutagenFamily
) -> bool:

	for mutagen in equipped_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_family == required_family:
			return true

	return false


func is_duo_active(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if not mutagen.has_duo_effect:
		return false

	return has_duo_partner(
		mutagen
	)

#func is_duo_active(
	#mutagen: MutagenResource
#) -> bool:
#
	#if mutagen == null:
		#return false
#
	#if mutagen.mutagen_type != (
		#MutagenResource.MutagenType.DUO
	#):
#
		#print(
			#"DUO INACTIVE:",
			#mutagen.mutagen_name
		#)
#
		#return false
#
	## ==================================================
	## Exact Mutagen Requirement
	## ==================================================
#
	#if not mutagen.required_mutagen_id.is_empty():
#
		#var found_required_mutagen := false
#
		#for equipped in equipped_mutagens:
#
			#if equipped == null:
				#continue
#
			#if equipped.mutagen_id == (
				#mutagen.required_mutagen_id
			#):
#
				#found_required_mutagen = true
				#break
#
		#if not found_required_mutagen:
#
			#print(
				#"DUO INACTIVE:",
				#mutagen.mutagen_name
			#)
#
			#return false
#
	## ==================================================
	## Required Mutagen Types
	## ==================================================
#
	#for required_type in mutagen.duo_required_types:
#
		#if not has_mutagen_type(
			#required_type
		#):
#
			#print(
				#"DUO INACTIVE:",
				#mutagen.mutagen_name
			#)
#
			#return false
#
	## ==================================================
	## Required Mutagen Families
	## ==================================================
#
	#for required_family in mutagen.duo_required_families:
#
		#if not has_mutagen_family(
			#required_family
		#):
#
			#print(
				#"DUO INACTIVE:",
				#mutagen.mutagen_name
			#)
#
			#return false
#
	## ==================================================
	## All Requirements Passed
	## ==================================================
#
	#print(
		#"DUO ACTIVE:",
		#mutagen.mutagen_name,
		#"| Types:",
		#mutagen.duo_required_types,
		#"| Families:",
		#mutagen.duo_required_families
	#)
#
	#return true


func has_duo_partner(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if not mutagen.has_duo_effect:
		return false

	# ==================================================
	# Exact Mutagen Requirement
	# ==================================================

	if not mutagen.duo_required_mutagen_id.is_empty():

		for equipped in equipped_mutagens:

			if equipped == null:
				continue

			if equipped == mutagen:
				continue

			if equipped.mutagen_id == (
				mutagen.duo_required_mutagen_id
			):

				return true

		return false

	# ==================================================
	# Required Families
	# ==================================================

	for required_family in (
		mutagen.duo_required_families
	):

		var found_family := false

		for equipped in equipped_mutagens:

			if equipped == null:
				continue

			if equipped == mutagen:
				continue

			if equipped.mutagen_family == required_family:

				found_family = true
				break

		if not found_family:
			return false

	# ==================================================
	# Required Types
	# ==================================================

	for required_type in (
		mutagen.duo_required_types
	):

		var found_type := false

		for equipped in equipped_mutagens:

			if equipped == null:
				continue

			if equipped == mutagen:
				continue

			if equipped.mutagen_type == required_type:

				found_type = true
				break

		if not found_type:
			return false

	return true


func is_mutagen_active(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	return true
#func is_mutagen_active(
	#mutagen: MutagenResource
#) -> bool:
#
	#if mutagen == null:
		#return false
#
	#if mutagen.mutagen_type == (
		#MutagenResource.MutagenType.DUO
	#):
#
		#return is_duo_active(
			#mutagen
		#)
#
	#return true


func get_duo_attack_bonus(
	mutagen: MutagenResource
) -> int:

	if mutagen == null:
		return 0

	if not has_duo_partner(mutagen):
		return 0

	return mutagen.duo_attack_bonus


# ==================================================
# Family Selection
# ==================================================

func get_mutagen_family_name(
	family: MutagenResource.MutagenFamily
) -> String:

	match family:

		MutagenResource.MutagenFamily.FERAL:
			return "Feral"

		MutagenResource.MutagenFamily.INFERNO:
			return "Inferno"

		MutagenResource.MutagenFamily.STORM:
			return "Storm"

		MutagenResource.MutagenFamily.VENOM:
			return "Venom"

		MutagenResource.MutagenFamily.PREDATOR:
			return "Predator"

		MutagenResource.MutagenFamily.CARAPACE:
			return "Carapace"

		MutagenResource.MutagenFamily.VITALITY:
			return "Vitality"

		MutagenResource.MutagenFamily.INSTINCT:
			return "Instinct"

		MutagenResource.MutagenFamily.SCAVENGER:
			return "Scavenger"

		_:
			return "Unknown"


func get_available_families() -> Array[MutagenResource.MutagenFamily]:

	var families: Array[MutagenResource.MutagenFamily] = []

	if mutagen_database == null:
		return families

	if run_manager == null:
		return families

	var current_world: int = run_manager.current_world

	for mutagen in mutagen_database.all_mutagens:

		if mutagen == null:
			continue

		# ------------------------------------------
		# World restriction
		# ------------------------------------------

		if not mutagen.is_available_in_world(
			current_world
		):

			continue

		# ------------------------------------------
		# Eligibility restriction
		# ------------------------------------------

		if not is_mutagen_eligible(
			mutagen
		):

			continue

		# ------------------------------------------
		# Add family once
		# ------------------------------------------

		if mutagen.mutagen_family not in families:

			families.append(
				mutagen.mutagen_family
			)

	return families


func choose_weighted_mutagen_family() -> MutagenResource.MutagenFamily:

	var families := get_available_families()

	if families.is_empty():

		push_error(
			"RunMutagenManager: No Mutagen families available."
		)

		return MutagenResource.MutagenFamily.FERAL

	var total_weight: float = 0.0

	# ==================================================
	# Calculate Total Weight
	# ==================================================

	for family in families:

		total_weight += get_family_weight(
			family
		)

	# ==================================================
	# Weighted Roll
	# ==================================================

	var roll := randf_range(
		0.0,
		total_weight
	)

	var running_weight: float = 0.0

	for family in families:

		running_weight += get_family_weight(
			family
		)

		if roll <= running_weight:

			return family

	return families.back()


# ==================================================
# Mutagen Progression
# ==================================================

func owns_mutagen_id(
	mutagen_id: String
) -> bool:

	if mutagen_id.is_empty():
		return false

	for mutagen in equipped_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_id == mutagen_id:
			return true

	if reserve_mutagen != null:

		if reserve_mutagen.mutagen_id == mutagen_id:
			return true

	return false


func is_mutagen_eligible(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if run_manager == null:
		return false


	# ==================================================
	# World Restriction
	# ==================================================

	if not mutagen.is_available_in_world(
		run_manager.current_world
	):

		return false

	# ==================================================
	# Already Owned
	# ==================================================

	if owns_mutagen_id(
		mutagen.mutagen_id
	):

		return false

	# ==================================================
	# Required Previous Mutagen
	# ==================================================

	if not mutagen.required_mutagen_id.is_empty():

		if not owns_mutagen_id(
			mutagen.required_mutagen_id
		):

			return false

	return true


# ==================================================
# Duo Requirements
# ==================================================

	#if mutagen.mutagen_type == MutagenResource.MutagenType.DUO:
#
		#for required_family in mutagen.required_families:
#
			#var family_found: bool = false
#
			#for equipped in equipped_mutagens:
#
				#if equipped == null:
					#continue
#
				#if equipped.mutagen_family == required_family:
#
					#family_found = true
					#break
#
			#if not family_found:
#
				#if reserve_mutagen != null:
#
					#if (
						#reserve_mutagen.mutagen_family
						#== required_family
					#):
#
						#family_found = true
#
			#if not family_found:
#
				#return false


# ==================================================
# Generate Mutagen Choices
# ==================================================
func generate_mutagen_choices(
	family: MutagenResource.MutagenFamily
) -> Array[MutagenResource]:

	var candidates: Array[MutagenResource] = (
		get_mutagens_by_family(
			family
		)
	)

	var available_choices: Array[MutagenResource] = []

	for mutagen in candidates:

		if mutagen == null:
			continue

		if not is_mutagen_eligible(
			mutagen
		):
			continue

		available_choices.append(
			mutagen
		)

	available_choices.shuffle()

	var choices: Array[MutagenResource] = []

	for mutagen in available_choices:

		if choices.size() >= 3:
			break

		choices.append(
			mutagen
		)

	return choices
	
#func generate_mutagen_choices(
	#family: MutagenResource.MutagenFamily
#) -> Array[MutagenResource]:
#
	#var candidates: Array[MutagenResource] = (
		#get_mutagens_by_family(
			#family
		#)
	#)
#
	#if candidates.is_empty():
#
		#print(
			#"No Mutagens available for family:",
			#get_mutagen_family_name(family)
		#)
#
		#return []
#
	## ==================================================
	## Filter
	## ==================================================
#
	#var available_choices: Array[MutagenResource] = []
#
	#for mutagen in candidates:
#
		#if mutagen == null:
			#continue
#
		#if not is_mutagen_eligible(
			#mutagen
		#):
#
			#continue
#
		#available_choices.append(
			#mutagen
		#)
#
	## ==================================================
	## Randomize
	## ==================================================
#
	#available_choices.shuffle()
#
	## ==================================================
	## Pick Up To Three
	## ==================================================
#
	#var choices: Array[MutagenResource] = []
#
	#for mutagen in available_choices:
#
		#if choices.size() >= 3:
			#break
#
		#choices.append(
			#mutagen
		#)
#
	#return choices
#

# ==================================================
# Run Reset
# ==================================================

func reset() -> void:

	equipped_mutagens.clear()

	reserve_mutagen = null

	print(
		"RUN MUTAGENS RESET"
	)

	mutagens_changed.emit()
