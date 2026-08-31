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

	# ==================================================
	# Electric
	# ==================================================

	_add_mutagen(
		"res://Data/Mutagens/Storm/ElectricGuardI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Srorm/ElectricGuardII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Storm/ElectricGuardIII.tres"
	)



	_add_mutagen(
		"res://Data/Mutagens/Inferno/BurningFangsI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Inferno/BurningFangsII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Inferno/BurningFangsIII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Predator/EnhancedVisionI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Predator/EnhancedVisionII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Predator/EnhancedVisionIII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Instinct/EvasionI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Instinct/EvasionII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Instinct/EvasionIII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Vitality/HealingBoostI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Vitality/HealingBoostII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Vitality/HealingBoostIII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Storm/ThunderBiteI.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Storm/ThunderBiteII.tres"
	)

	_add_mutagen(
		"res://Data/Mutagens/Storm/ThunderBiteIII.tres"
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

		if not mutagen.is_available_in_world(world):
			continue

		results.append(
			mutagen
		)

	return results
