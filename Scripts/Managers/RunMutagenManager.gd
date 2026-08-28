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
const MATCHING_TAG_WEIGHT: float = 5.0


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

			weight += MATCHING_TAG_WEIGHT

		for tag in mutagen.tags:

			if _family_matches_tag(
				family,
				tag
			):

				weight += MATCHING_TAG_WEIGHT

	return weight


func _family_matches_tag(
	family: MutagenResource.MutagenFamily,
	tag: MutagenResource.MutagenTag
) -> bool:

	match family:

		MutagenResource.MutagenFamily.ATTACK:

			return tag == MutagenResource.MutagenTag.ATTACK

		MutagenResource.MutagenFamily.DEFENSE:

			return tag == MutagenResource.MutagenTag.DEFENSE

		MutagenResource.MutagenFamily.SPEED:

			return tag == MutagenResource.MutagenTag.SPEED

		MutagenResource.MutagenFamily.CRITICAL:

			return tag == MutagenResource.MutagenTag.CRITICAL

		MutagenResource.MutagenFamily.HP:

			return tag == MutagenResource.MutagenTag.HP

		MutagenResource.MutagenFamily.EVASION:

			return tag == MutagenResource.MutagenTag.EVASION

		MutagenResource.MutagenFamily.REWARDS:

			return false

		MutagenResource.MutagenFamily.BITE:

			return tag == MutagenResource.MutagenTag.BITE

		MutagenResource.MutagenFamily.PROTECT:

			return tag == MutagenResource.MutagenTag.PROTECT

		MutagenResource.MutagenFamily.FIRE:

			return tag == MutagenResource.MutagenTag.FIRE

		MutagenResource.MutagenFamily.ELECTRIC:

			return tag == MutagenResource.MutagenTag.ELECTRIC

		MutagenResource.MutagenFamily.POISON:

			return tag == MutagenResource.MutagenTag.POISON

		MutagenResource.MutagenFamily.BLEED:

			return tag == MutagenResource.MutagenTag.BLEED

		MutagenResource.MutagenFamily.HEALING:

			return false

		_:
			return false


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

	var removed: MutagenResource = (
		reserve_mutagen
	)

	reserve_mutagen = null

	print(
		"RESERVE MUTAGEN REMOVED:",
		removed.mutagen_name
	)

	mutagens_changed.emit()

	return removed


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


# ==================================================
# Family Selection
# ==================================================

func get_mutagen_family_name(
	family: MutagenResource.MutagenFamily
) -> String:

	match int(family):

		0:
			return "Attack"

		1:
			return "Defense"

		2:
			return "Speed"

		3:
			return "Critical"

		4:
			return "Health"

		5:
			return "Healing"

		6:
			return "Evasion"

		7:
			return "Rewards"

		8:
			return "Bite"

		9:
			return "Protect"

		10:
			return "Fire"

		11:
			return "Electric"

		12:
			return "Poison"

		13:
			return "Bleed"

		_:
			return "Other"


func get_available_families() -> Array[MutagenResource.MutagenFamily]:

	var families: Array[MutagenResource.MutagenFamily] = []

	if mutagen_database == null:
		return families

	var current_world: int = run_manager.current_world

	for mutagen in mutagen_database.all_mutagens:

		if mutagen == null:
			continue

		if not mutagen.is_available_in_world(
			current_world
		):

			continue

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

		return MutagenResource.MutagenFamily.OTHER

	var total_weight: float = 0.0

	for family in families:

		total_weight += get_family_weight(
			family
		)

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

	return false


func is_mutagen_eligible(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	# World restriction
	if run_manager == null:
		return false

	if not mutagen.is_available_in_world(
		run_manager.current_world
	):

		return false

	# Required previous Mutagen
	if not mutagen.required_mutagen_id.is_empty():

		if not owns_mutagen_id(
			mutagen.required_mutagen_id
		):

			return false

	return true


func generate_mutagen_choices(
	family: MutagenResource.MutagenFamily
) -> Array[MutagenResource]:

	var candidates: Array[MutagenResource] = []

	if mutagen_database == null:

		push_error(
			"RunMutagenManager: MutagenDatabase is missing."
		)

		return candidates

	for mutagen in mutagen_database.all_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_family != family:
			continue

		if not is_mutagen_eligible(mutagen):
			continue

		candidates.append(
			mutagen
		)

	candidates.shuffle()

	var choices: Array[MutagenResource] = []

	for mutagen in candidates:

		if choices.size() >= 3:
			break

		choices.append(
			mutagen
		)

	return choices


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
