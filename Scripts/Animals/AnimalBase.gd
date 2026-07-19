extends Node2D
class_name AnimalBase


signal hp_changed(new_hp)


var run_manager

var animal_resource : AnimalResource

# -------------------------------------------------------------------
# BASE STATS
# -------------------------------------------------------------------

var base_hp := 100
var hp := 100

var base_attack := 5
var base_speed := 10

var base_accuracy := 100
var base_evasion := 0
var base_armor := 0


# -------------------------------------------------------------------
# COMBAT STATES
# -------------------------------------------------------------------


var is_protecting := false

# 80% damage reduction
var protect_reduction := 0.8


# -------------------------------------------------------------------
# GENES
# -------------------------------------------------------------------


var equipped_genes: Array[GeneResource] = []

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


# -------------------------------------------------------------------
# MOVES
# -------------------------------------------------------------------

var learned_moves: Array[MoveResource] = []
var basic_moves:Array[MoveResource] = []
var gene_moves:Array[MoveResource] = []
var selected_moves:Array[MoveResource] = []

# -------------------------------------------------------------------
# PASSIVES / STATUS EFFECTS
# -------------------------------------------------------------------

var passive_effects: Array = []
var status_effects: Array = []


func process_status_effects():
	for effect in status_effects:
		match effect.type:
			StatusEffect.Type.POISON:
				
				print(
					name,
					" takes poison damage"
				)

				take_damage(effect.power)
				
			StatusEffect.Type.BLEED:

				print(
					name,
					" bleeds"
				)

				take_damage(effect.power)

		effect.duration -= 1
		
	status_effects = status_effects.filter(
		func(e):
			return e.duration > 0
	)

# -------------------------------------------------------------------
# GENE MANAGEMENT
# -------------------------------------------------------------------


func add_gene(gene: GeneResource) -> bool:

	if gene == null:
		return false

	var slot = gene.slot_type
	var current_list: Array = gene_slots[slot]

	var used_cost := 0

	for g in current_list:
		used_cost += g.slot_cost

	if used_cost + gene.slot_cost > slot_capacity[slot]:
		print("No space for gene:", gene.gene_name)
		return false

	current_list.append(gene)

	gene_slots[slot] = current_list

	equipped_genes.append(gene)


	# Add gene passive effects
	for passive in gene.passive_effects:
		if passive:
			passive_effects.append(passive)


	# Add gene moves
	for move in gene.move_pool:
		if move:
			gene_moves.append(move)

	print(
		name,
		" equipped gene:",
		gene.gene_name
	)

	return true


func get_battle_moves():
	var moves:Array[MoveResource] = []
	
	moves.append_array(basic_moves)

	moves.append_array(selected_moves)

	return moves

# -------------------------------------------------------------------
# MOVE SYSTEM
# -------------------------------------------------------------------


func add_move(move: MoveResource):

	if move == null:
		return

	gene_moves.append(move)

	print(
		name,
		" learned gene move:",
		move.move_name
	)


func get_move(index: int):
	
	var moves = get_battle_moves()
	
	if index < 0:
		return null

	if index >= moves.size():
		return null

	return moves[index]


func use_move(index: int,target):

	var move = get_move(index)

	if move == null:
		return

	move.execute(
		self,
		target
	)


# -------------------------------------------------------------------
# STATS
# -------------------------------------------------------------------


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


func get_accuracy() -> int:
	
	var value = 0
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			if "accuracy_bonus" in gene:
				value += gene.accuracy_bonus
			
	return value
		
func get_evasion() -> int:
	
	var value = base_evasion
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.evasion_bonus
			
	return clamp(value, 0, 90)

func calculate_hit_chance(target, move_accuracy: int) -> int:
	
	var chance = move_accuracy + get_accuracy() - target.get_evasion()
	
	print(
		name,
		" move accuracy:",
		move_accuracy,
		" accuracy_bonus:",
		get_accuracy(),
		" target evasion:",
		target.get_evasion(),
		" final chance:",
		chance
	)

	return clamp(chance, 10, 100)
	
	
func get_armor() -> int:
	var value = base_armor
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.armor_bonus
			
	return value
	
func calculate_damage_taken(amount: int) -> int:
	
	var armor = get_armor()
	
	var reduction = armor * 0.01
	
	var final_damage = amount * (1.0 - reduction)
	
	return max(1, int(final_damage))
	
	
func setup_player_hp(manager):

	run_manager = manager

	hp = manager.player_hp

	print(
		"Loaded player HP:",
		hp,
		"/",
		manager.max_hp
	)
	
# -------------------------------------------------------------------
# DAMAGE
# -------------------------------------------------------------------


func take_damage(amount: int):
	if is_protecting:

		amount = int(
			amount * (1.0 - protect_reduction)
		)

		print(
			name,
			" blocked damage with protect"
		)

	hp -= amount

	hp = clamp(
		hp,
		0,
		get_max_hp()
	)


	print(
		name,
		" took ",
		amount,
		" damage. HP:",
		hp
	)

	hp_changed.emit(hp)

	#if self is PlayerAnimal:
#
		#var run_manager = get_node("../../RunManager")
#
		#if run_manager:
			#run_manager.player_hp = hp

# -------------------------------------------------------------------
# TURN MANAGEMENT
# -------------------------------------------------------------------


func reset_turn_state():

	# temporary effects expire here

	is_protecting = false


func activate_protect():

	is_protecting = true

	print(
		name,
		" is protecting"
	)


func clear_protect():
	is_protecting = false


# -------------------------------------------------------------------
# PASSIVE EFFECT SYSTEM
# -------------------------------------------------------------------


func trigger_passive_event(event_name: String):

	for passive in passive_effects:

		match event_name:

			"battle_start":

				if passive.has_method("on_battle_start"):
					passive.on_battle_start(self)

			"turn_start":

				if passive.has_method("on_turn_start"):
					passive.on_turn_start(self)

			"turn_end":

				if passive.has_method("on_turn_end"):
					passive.on_turn_end(self)


# -------------------------------------------------------------------
# BASIC MOVES
# -------------------------------------------------------------------


func setup_basic_moves():
	
	basic_moves.clear()

	if animal_resource == null:
		print("No animal resource")
		return

	for move in animal_resource.starter_moves:
		basic_moves.append(move)
		
		print(
			name,
			" learned basic move:",
			move.move_name
		)
		
	#gene_moves.clear()
#
	#var attack = MoveResource.new()
#
	#attack.move_name = "Attack"
	#attack.power = 5
	#attack.priority = 0
#
	#basic_moves.append(attack)
#
#
	#var protect = MoveResource.new()
#
	#protect.move_name = "Protect"
	#protect.power = -1
	#protect.priority = 2
#
	#basic_moves.append(protect)
#
	#print(
		#name,
		#" learned basic moves"
	#)


# -------------------------------------------------------------------
# LEGENDARY MUTATION PLACEHOLDER
# -------------------------------------------------------------------


func get_synergy_bonus(slot: GeneResource.SlotType) -> int:
	
	var genes = gene_slots[slot]

	if genes.size() >= 2:
		return 1

	return 0
