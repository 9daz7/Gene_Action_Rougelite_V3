extends Resource
class_name PotionResource


# ==================================================
# Potion Type
# ==================================================

enum PotionType {
	HEAL,
	STAT
}

# ==================================================
# Information
# ==================================================

@export var potion_name: String = ""
@export_multiline var description: String = ""

@export var potion_type: PotionType = PotionType.HEAL

@export var duration:int = 3


# ==================================================
# Effect
# ==================================================

@export var heal_amount: int = 0

@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0
