extends Node2D
class_name AnimalBase

signal hp_changed(new_hp)

var base_hp := 100
var hp := 100

var base_attack := 10
var base_speed := 10


# Gene slots
var gene_slots := {
	GeneResource.SlotType.MOUTH: [],
	GeneResource.SlotType.SKIN: [],
	GeneResource.SlotType.MUSCLE: [],
	GeneResource.SlotType.CLAWS: [],
	GeneResource.SlotType.LIMBS: [],
	GeneResource.SlotType.GLANDS: []
}


var slot_capacity := {
	GeneResource.SlotType.MOUTH: 2,
	GeneResource.SlotType.SKIN: 2,
	GeneResource.SlotType.MUSCLE: 2,
	GeneResource.SlotType.CLAWS: 2,
	GeneResource.SlotType.LIMBS: 2,
	GeneResource.SlotType.GLANDS: 2
}


#
# GENES
#

func add_gene(gene: GeneResource) -> bool:
	if gene == null:
		return false

	var slot = gene.slot_type
	var current_list:Array = gene_slots[slot]

	var used_cost := 0
	for g in current_list:
		used_cost += g.slot_cost

	if used_cost + gene.slot_cost > slot_capacity[slot]:
		return false

	current_list.append(gene)
	gene_slots[slot] = current_list

	return true


#
# STATS
#

func get_attack() -> int:
	var value = base_attack

	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.attack_bonus

	return value



func get_max_hp() -> int:
	var value = base_hp

	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.hp_bonus

	return value


func get_speed() -> int:
	var value = base_speed

	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.speed_bonus

	return value


#
# DAMAGE
#

func take_damage(amount:int):
	hp -= amount
	hp = clamp(hp, 0, get_max_hp())
	hp_changed.emit(hp)


#
# LEGENDARY MUTATIONS (placeholder)
#

func get_synergy_bonus(slot:GeneResource.SlotType) -> int:
	var genes = gene_slots[slot]

	if genes.size() >= 2:
		return 1

	return 0
