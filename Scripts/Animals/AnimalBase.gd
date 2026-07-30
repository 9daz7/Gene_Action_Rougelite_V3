extends Node2D
class_name AnimalBase

# ==================================================
# Signals
# ==================================================


signal hp_changed(current_hp)
signal animal_died


# ==================================================
# References
# ==================================================


var run_manager: RunManager
var animal_resource: AnimalResource


# ==================================================
# Initialization
# ==================================================


func initialize(resource: AnimalResource):
	
	animal_resource = resource
	
	setup_basic_moves()


# ==================================================
# Identity
# ==================================================


func get_display_name() -> String:
	return name


# ==================================================
# BASE STATS/MODIFIERS
# ==================================================

var base_hp := 100
var hp := 100

var base_attack := 5
var base_speed := 10

var base_accuracy := 100
var base_evasion := 0
var base_armor := 0


# Temporary battle stat modifiers
var speed_modifier:int = 0
var attack_modifier:int = 0
var defense_modifier:int = 0
var accuracy_modifier:int = 0
var evasion_modifier:int = 0
var armor_modifier:int = 0


# ==================================================
# GENES
# ==================================================


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


func load_genes(genes:Array):
	for gene in genes:

		if gene:
			add_gene(gene)



func get_synergy_bonus(slot: GeneResource.SlotType) -> int:
	
	var genes = gene_slots[slot]

	if genes.size() >= 2:
		return 1

	return 0


# ==================================================
# MOVES
# ==================================================

var learned_moves: Array[MoveResource] = []
var basic_moves:Array[MoveResource] = []
var gene_moves:Array[MoveResource] = []
var selected_moves:Array[MoveResource] = []


func setup_basic_moves():
	
	basic_moves.clear()

	if animal_resource == null:
		print("No animal resource")
		return
		
	if not "starter_moves" in animal_resource:
		print("Animal has no starter moves")
		return

	for move in animal_resource.starter_moves:
		
		if move:
			basic_moves.append(move)
		
			print(
				name,
				" learned:",
				move.move_name
			)


func add_move(move: MoveResource):

	if move == null:
		return

	selected_moves.append(move)

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


func get_battle_moves():
	var moves:Array[MoveResource] = []
	
	moves.append_array(basic_moves)

	moves.append_array(selected_moves)

	return moves


func use_move(index: int,target):

	var move = get_move(index)

	if move == null:
		return

	move.execute(
		self,
		target
	)


# ==================================================
# PASSIVES / STATUS EFFECTS
# ==================================================

var passive_effects: Array = []
var status_effects: Array = []


func process_status_effects():
	for effect in status_effects:
		
		match effect.type:
			
			StatusEffect.Type.POISON:
				print(name," takes poison damage")
				take_damage(effect.power)
				
			StatusEffect.Type.BLEED:
				print(name," bleeds")
				take_damage(effect.power)
				
			StatusEffect.Type.BURN:
				print(name," burns")
				take_damage(effect.power)

		effect.duration -= 1
		
	for effect in status_effects.duplicate():
		if effect.duration <= 0:
			remove_status_effect(effect)


func apply_status_effect(effect:StatusEffect):

	if effect == null:
		return

	effect.apply(self)

	print(
		name,
		" received ",
		effect.effect_name
	)
	
	
func remove_status_effect(effect:StatusEffect):

	match effect.type:
		StatusEffect.Type.SPEED_UP:
			speed_modifier -= effect.power

		StatusEffect.Type.SPEED_DOWN:
			speed_modifier += effect.power

		StatusEffect.Type.ATTACK_UP:
			attack_modifier -= effect.power

		StatusEffect.Type.ATTACK_DOWN:
			attack_modifier += effect.power

		StatusEffect.Type.DEFENSE_UP:
			defense_modifier -= effect.power

		StatusEffect.Type.DEFENSE_DOWN:
			defense_modifier += effect.power

	status_effects.erase(effect)

	print(
		effect.effect_name,
		" expired on ",
		name
	)


# ==================================================
# STATS
# ==================================================


func get_attack() -> int:

	var value = base_attack + attack_modifier

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

	var value = base_speed + speed_modifier

	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.speed_bonus

	print(
		name,
		" current speed:",
		value
	)
	
	return value


func get_accuracy() -> int:
	
	var value = base_accuracy + accuracy_modifier
	
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


func get_armor() -> int:
	var value = base_armor + defense_modifier
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.armor_bonus
			
	return value


func modify_attack(amount:int):
	attack_modifier += amount


func modify_speed(amount:int):
	speed_modifier += amount


func modify_defense(amount:int):
	defense_modifier += amount


func modify_accuracy(amount:int):
	accuracy_modifier += amount


func modify_evasion(amount:int):
	evasion_modifier += amount
	
	
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


func setup_player_hp(manager):

	run_manager = manager

	hp = manager.player_hp

	print(
		"Loaded player HP:",
		hp,
		"/",
		manager.max_hp
	)


# ==================================================
# Combat Functions
# ==================================================

var is_protecting := false

# 80% damage reduction
var protect_reduction := 0.8


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

	GameEvents.hp_changed.emit(
		self,
		hp,
		get_max_hp()
	)

	hp_changed.emit(hp)
	
	if hp <= 0:
		die()


func die():
	hp = 0
	
	animal_died.emit()

	print(
		name,
		" has been defeated"
	)
	

func is_alive() -> bool:
	return hp > 0
	
	
func heal(amount:int):
	
	hp += amount

	hp = clamp(
		hp,
		0,
		get_max_hp()
	)

	GameEvents.hp_changed.emit(
		self,
		hp,
		get_max_hp()
	)

	hp_changed.emit(hp)


func calculate_damage_taken(amount: int) -> int:
	
	var armor = get_armor()
	
	var reduction = armor * 0.01
	
	var final_damage = amount * (1.0 - reduction)
	
	return max(1, int(final_damage))


func get_current_hp() -> int:
	return hp


# ==================================================
# TURN MANAGEMENT
# ==================================================


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


# ==================================================
# PASSIVE EFFECTS
# ==================================================


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


# ==================================================
# Resource Loading
# ==================================================


func load_animal_stats(resource):
	if resource == null:
		print("No animal resource")
		return

	base_hp = resource.base_hp
	base_attack = resource.base_attack
	base_speed = resource.base_speed


func load_build(build: AnimalBuildResource):
	if build == null:
		print("No build")
		return

	name = build.animal_name

	animal_resource = build.animal

	if animal_resource:
		base_hp = animal_resource.base_hp
		base_attack = animal_resource.base_attack
		base_speed = animal_resource.base_speed

	equipped_genes.clear()
	
	learned_moves.clear()
	basic_moves.clear()
	gene_moves.clear()
	selected_moves.clear()

	setup_basic_moves()

	for gene in build.genes:
		add_gene(gene)

	for move in build.moves:
		add_move(move)
