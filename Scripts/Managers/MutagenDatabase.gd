extends Node
class_name MutagenDatabase


# ==================================================
# All Mutagens
# ==================================================

var all_mutagens: Array[MutagenResource] = []


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("MUTAGEN DATABASE READY")


func initialize() -> void:

	print("================================")
	print("INITIALIZING MUTAGEN DATABASE")
	print("================================")

	load_mutagens()


# ==================================================
# Load Mutagens
# ==================================================

func load_mutagens() -> void:

	all_mutagens.clear()

	_add_mutagen(
		"res://Data/Mutagens/BurningFangs.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/ElectricGuard.tres"
	)
	
	_add_mutagen(
		"res://Data/Mutagens/EnhancedVision.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Evasion.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/HealingBoost.tres"
	)


	print(
		"Total Mutagens:",
		all_mutagens.size()
	)


func _add_mutagen(
	path: String
) -> void:

	var mutagen := load(
		path
	) as MutagenResource

	if mutagen == null:

		push_error(
			"MutagenDatabase: Failed to load Mutagen: "
			+ path
		)

		return

	all_mutagens.append(
		mutagen
	)


	print(
		"--------------------------------"
	)

	print(
		"Loaded Mutagen:",
		mutagen.mutagen_name
	)

	print(
		"Family value:",
		mutagen.mutagen_family
	)

	print(
		"Family name:",
		mutagen.get_family_name()
	)

	print(
		"Tags:",
		mutagen.tags
	)

	print(
		"--------------------------------"
	)


# ==================================================
# Queries
# ==================================================

func get_mutagens_by_family(
	family: MutagenResource.MutagenFamily,
	world: int
) -> Array[MutagenResource]:

	var results: Array[MutagenResource] = []

	for mutagen in all_mutagens:

		if mutagen == null:
			continue

		if mutagen.mutagen_family != family:
			continue

		if not mutagen.is_available_in_world(world):
			continue

		results.append(
			mutagen
		)

	return results


func get_mutagens_for_world(
	world: int
) -> Array[MutagenResource]:

	var results: Array[MutagenResource] = []

	for mutagen in all_mutagens:

		if mutagen == null:
			continue

		results.append(
			mutagen
		)

	return results
