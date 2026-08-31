extends Resource
class_name MutagenResource


# ==================================================
# Mutagen Types
# ==================================================

enum MutagenType {
	STAT = 0,
	ABILITY = 1,
	TRIGGER = 2,
	CONDITIONAL = 3,
	TRANSFORMATION = 4,
	DUO = 5
}

@export var mutagen_type: MutagenType = MutagenType.STAT


# ==================================================
# Mutagen Tier
# ==================================================

enum MutagenTier {
	TIER_1 = 1,
	TIER_2 = 2,
	TIER_3 = 3
}

@export var tier: MutagenTier = MutagenTier.TIER_1


# ==================================================
# Tier Progression
# ==================================================

@export var requires_previous_tier: bool = true


# ==================================================
# Upgrade Chain
# ==================================================

@export var mutagen_id: String = ""
@export var required_mutagen_id: String = ""


# ==================================================
# World Availability
# ==================================================

@export var minimum_world: int = 1
@export var maximum_world: int = 2


# ==================================================
# Mutagen Families
# ==================================================

enum MutagenFamily {
	FERAL = 0,
	INFERNO = 1,
	STORM = 2,
	VENOM = 3,
	PREDATOR = 4,
	CARAPACE = 5,
	VITALITY = 6,
	INSTINCT = 7,
	SCAVENGER = 8
}

@export var mutagen_family: MutagenFamily = MutagenFamily.FERAL


# ==================================================
# Duo Requirements
# ==================================================

@export var required_families: Array[MutagenFamily] = []


# ==================================================
# Mutagen Tags
# ==================================================

enum MutagenTag {
	ATTACK = 0,
	DEFENSE = 1,
	SPEED = 2,
	CRITICAL = 3,
	HP = 4,
	HEALING = 5,
	EVASION = 6,
	REWARDS = 7,

	FIRE = 8,
	ELECTRIC = 9,
	POISON = 10,
	BLEED = 11,

	BURN = 12,
	STATIC = 13,
	SHOCK = 14,

	REGENERATION = 15,
	THORNS = 16,
	EXECUTE = 17,
	CHAIN = 18,
	GOLD = 19
}

@export var tags: Array[MutagenTag] = []


# ==================================================
# Information
# ==================================================

@export var mutagen_name: String = ""
@export_multiline var description: String = ""


# ==================================================
# Stat Bonuses
# ==================================================

@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0
@export var hp_bonus: int = 0
@export var accuracy_bonus: int = 0
@export var evasion_bonus: int = 0
@export var armor_bonus: int = 0
@export var crit_bonus: int = 0


# ==================================================
# Move Targeting
# ==================================================

@export var affected_move_names: Array[String] = []


# ==================================================
# Move Bonuses
# ==================================================

@export var damage_bonus: int = 0
@export var critical_bonus_for_move: int = 0
@export var accuracy_bonus_for_move: int = 0


# ==================================================
# Protect Trigger
# ==================================================

@export var triggers_on_physical_hit_while_protected: bool = false


# ==================================================
# Protect Bonuses
# ==================================================

@export var protect_reduction_bonus: float = 0.0


# ==================================================
# Added Status Effects
# ==================================================

@export var added_effects: Array[StatusEffect] = []


# ==================================================
# Helpers
# ==================================================

func affects_move(
	move: MoveResource
) -> bool:

	if move == null:
		return false

	return move.move_name in affected_move_names


func get_family_name() -> String:

	match mutagen_family:

		MutagenFamily.FERAL:
			return "Feral"

		MutagenFamily.INFERNO:
			return "Inferno"

		MutagenFamily.STORM:
			return "Storm"

		MutagenFamily.VENOM:
			return "Venom"

		MutagenFamily.PREDATOR:
			return "Predator"

		MutagenFamily.CARAPACE:
			return "Carapace"

		MutagenFamily.VITALITY:
			return "Vitality"

		MutagenFamily.INSTINCT:
			return "Instinct"

		MutagenFamily.SCAVENGER:
			return "Scavenger"

		_:
			return "Unknown"


func is_available_in_world(
	world: int
) -> bool:

	return (
		world >= minimum_world
		and
		world <= maximum_world
	)


func has_tag(
	tag: MutagenTag
) -> bool:

	return tag in tags
