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
# Information
# ==================================================

@export var mutagen_name: String = ""
@export_multiline var description: String = ""

@export var mutagen_type: MutagenType = MutagenType.STAT


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
