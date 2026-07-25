extends Resource
class_name GeneResource


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


# Slot system
@export var slot_cost := 1


# Stats
@export var attack_bonus := 0
@export var hp_bonus := 0
@export var speed_bonus := 0
@export var defense_bonus := 0


# Accuracy / evasion
@export var accuracy_bonus := 0
@export var evasion_bonus := 0


# Defensive stats
@export var armor_bonus := 0


# @export var instability := 0


# Adaptation
@export var adaptation_cost := 1


# Passive abilities
@export var passive_effects: Array[PassiveEffect] = []


# Moves this gene unlocks
@export var move_pool: Array[MoveResource] = []


# Tags for future synergies
@export var tags: Array[String] = []


# Legendary mutation this gene can participate in
@export var legendary_links: Array[LegendaryMutation] = []


func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"

		Rarity.UNCOMMON:
			return "Uncommon"

		Rarity.RARE:
			return "Rare"

		Rarity.EPIC:
			return "Epic"

		_:
			return "Unknown"


 #Future implementation
 #@export var tags: Array[String] = []


 #Future properties
 #@export_multiline var description: String = ""
 #@export var icon: Texture2D
 #@export var species := ""
