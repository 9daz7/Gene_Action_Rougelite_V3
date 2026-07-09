extends Resource
class_name MutagenResource 

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

@export var mutagen_name : String = ""
@export_multiline var description : String = ""

@export var rarity : Rarity = Rarity.COMMON

# run only bonuses
@export var attack_bonus : int = 0
@export var hp_bonus : int = 0
@export var speed_bonus : int = 0
@export var armor_bonus : int = 0
@export var dodge_bonus : int = 0
@export var lifesteal : int = 0

#future
#@export var passive_effects : Array[PassiveEffect] = []
