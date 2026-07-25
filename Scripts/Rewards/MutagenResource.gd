extends Resource
class_name MutagenResource


enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}


@export var mutagen_name: String = ""
@export_multiline var description: String = ""

@export var rarity: Rarity = Rarity.COMMON


# Run-only bonuses
@export var attack_bonus := 0
@export var hp_bonus := 0
@export var speed_bonus := 0
@export var armor_bonus := 0
@export var dodge_bonus := 0
@export var lifesteal := 0


 #Future
 #@export var passive_effects: Array[PassiveEffect] = []
