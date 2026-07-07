extends Resource
class_name Gene

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

enum SlotType {
	MOUTH,
	SKIN,
	MUSCLE,
	CLAWS,
	LIMBS,
	GLANDS
}

@export var gene_name: String
@export var rarity: Rarity
@export var slot_type: SlotType

# slot system
@export var slot_cost: int = 1

# stats
@export var attack_bonus: int = 0
@export var hp_bonus := 0
@export var speed_bonus := 0
@export var defense_bonus := 0
#@export var instability := 0\

@export var adaptation_cost := 1

#future implimentation 
#@export var tags: Array[String] = []



#@export_multiline var description : String = ""
#@export var icon : Texture2D

#@export var species := ""
