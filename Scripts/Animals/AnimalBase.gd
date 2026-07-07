extends Node2D
class_name AnimalBase

signal hp_changed(new_hp)

var base_hp := 100
var hp := 100

var base_attack := 10
var base_speed := 10

# slot system
var gene_slots := {
	Gene.SlotType.MOUTH: [],
	Gene.SlotType.SKIN: [],
	Gene.SlotType.MUSCLE: [],
	Gene.SlotType.CLAWS: [],
	Gene.SlotType.LIMBS: [],
	Gene.SlotType.GLANDS: []
}

var slot_capacity := {
	Gene.SlotType.MOUTH: 2,
	Gene.SlotType.SKIN: 2,
	Gene.SlotType.MUSCLE: 2,
	Gene.SlotType.CLAWS: 2,
	Gene.SlotType.LIMBS: 2,
	Gene.SlotType.GLANDS: 2,
}

#
# GENES
#

func add_gene(gene: Gene) -> bool:
	if gene == null:
		return false
		
	var slot = gene.slot_type
	var current_list: Array = gene_slots[slot]
	
	# check capacity
	var used_cost := 0
	for g in current_list:
		used_cost += g.slot_cost
		
	if used_cost + gene.slot_cost > slot_capacity[slot]:
		return false
		
	current_list.append(gene)
	gene_slots[slot] = current_list
	
	return true
		
		
##
## CORE STATS
##

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
	
func take_damage(amount: int):
	hp -= amount
	hp = clamp(hp, 0, get_max_hp())
	hp_changed.emit(hp)
	
	
#
# legendary gene mutations
#

func get_synergy_bonus(slot: Gene.SlotType) -> int:
	var genes = gene_slots[slot]
	
	# example
	if genes.size() >= 2:
		# placeholder
		return 1
		
	return 0
