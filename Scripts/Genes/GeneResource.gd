extends Resource
class_name GeneResource


enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
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
@export_multiline var description: String = ""

@export var rarity: Rarity
@export var slot_type: SlotType

@export var icon: Texture2D


# ==================================================
# Slot System
# ==================================================

@export var slot_cost := 1


# Stats
@export var attack_bonus := 0
@export var hp_bonus := 0
@export var speed_bonus := 0
@export var defense_bonus := 0


# Accuracy / evasion
@export var accuracy_bonus := 0
@export var evasion_bonus := 0

@export var critical_bonus := 0


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


func get_passive_names() -> Array[String]:

	var names:Array[String] = []


	for passive in passive_effects:

		if passive:

			if passive.has_method("get_display_name"):
				names.append(passive.get_display_name())
			else:
				names.append(passive.resource_name)


	return names


func has_passive(passive_name:String) -> bool:

	for passive in passive_effects:

		if passive.effect_name == passive_name:

			return true


	return false


func get_move_names() -> Array[String]:

	var names:Array[String] = []


	for move in move_pool:

		if move:

			names.append(
				move.move_name
			)


	return names


func has_tag(tag:String) -> bool:

	return tag in tags


func print_summary():

	print("======================")
	print("GENE:", gene_name)
	print("RARITY:", get_rarity_name())
	print("SLOT:", SlotType.keys()[slot_type])

	print("STATS:")
	print(
		"HP:",
		hp_bonus,
		" ATK:",
		attack_bonus,
		" SPD:",
		speed_bonus
	)

	print(
		"PASSIVES:",
		get_passive_names()
	)

	print(
		"MOVES:",
		get_move_names()
	)

	print("======================")


 #Future properties

 #@export var species := ""
