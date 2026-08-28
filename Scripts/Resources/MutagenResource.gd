extends Resource
class_name MutagenResource


# ==================================================
# Mutagen Types
# ==================================================

enum MutagenType {
	STAT,
	MOVE
}


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
# Upgrade Chain
# ==================================================

@export var required_mutagen: String = ""

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
	ATTACK = 0,
	DEFENSE = 1,
	SPEED = 2,
	CRITICAL = 3,
	HP = 4,
	HEALING = 5,
	EVASION = 6,
	REWARDS = 7,
	BITE = 8,
	PROTECT = 9,
	FIRE = 10,
	ELECTRIC = 11,
	POISON = 12,
	BLEED = 13,
	OTHER = 14
}


# ==================================================
# Mutagen Tags
# ==================================================

enum MutagenTag {
	STAT,
	BITE,
	PROTECT,
	MOVE,
	ELECTRIC,
	FIRE,
	POISON,
	BLEED,
	SPEED,
	ATTACK,
	DEFENSE,
	HP,
	CRITICAL,
	HEALING,
	EVASION,
	REWARDS
}

@export var tags: Array[MutagenTag] = []


# ==================================================
# Information
# ==================================================

@export var mutagen_name: String = ""
@export_multiline var description: String = ""

@export var mutagen_type: MutagenType = MutagenType.STAT
@export var mutagen_family: MutagenFamily = MutagenFamily.OTHER


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

	match int(mutagen_family):

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

		14:
			return "Other"

		_:
			return "Other"


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
