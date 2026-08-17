extends Node2D
class_name AnimalBase

# ==================================================
# Signals
# ==================================================


#signal hp_changed(current_hp)
signal animal_died
signal status_changed(animal)


# ==================================================
# References
# ==================================================


var run_manager: RunManager
var animal_resource: AnimalResource
var turn_manager: TurnManager


# ==================================================
# Initialization
# ==================================================


func initialize(resource: AnimalResource):
	
	animal_resource = resource
	
	setup_basic_moves()

# ==================================================
# Team / Targeting
# ==================================================

func get_opponents() -> Array:

	if turn_manager == null:
		return []

	if self == turn_manager.player:
		return turn_manager.enemies

	return [turn_manager.player]


func get_team_members() -> Array:
	if turn_manager == null:
		return []

	if self == turn_manager.player:
		return [self]

	var allies: Array = []

	for enemy in turn_manager.enemies:
		if is_instance_valid(enemy) and enemy.hp > 0:
			allies.append(enemy)

	return allies

func get_all_enemies() -> Array:
	return get_opponents()


func get_all_allies() -> Array:
	return get_team_members()

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
var critical_modifier := 0


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
		
		if passive == null:
			continue

		if passive.has_method("initialize"):
			passive.initialize(gene)
			
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

	passive_effects.clear()
	equipped_genes.clear()
	gene_moves.clear()

	for slot in gene_slots:
		gene_slots[slot].clear()

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

#var learned_moves: Array[MoveResource] = []
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
		
	#for passive in passive_effects:
		#passive.on_before_attack(
			#self,
			#target
		#)

	move.execute(
		self,
		target
	)


# ==================================================
# PASSIVES / STATUS EFFECTS
# ==================================================

var passive_effects: Array[PassiveEffect] = []
var status_effects: Array = []


func process_status_effects():

	if not is_alive():
		return

	for effect in status_effects.duplicate():

		if effect == null:
			continue

		if not is_instance_valid(effect):
			continue

		if not is_alive():
			return

		effect.process_turn(
			self
		)


func apply_status_effect(effect:StatusEffect):

	if effect == null:
		return


	# ==========================================
	# Check for existing status
	# ==========================================


	for existing in status_effects:

		if existing.type != effect.type:
			continue

		# --------------------------------------
		# Refresh duration
		# --------------------------------------

		if existing.refresh_duration:

			existing.duration = effect.duration

			print(
				existing.effect_name,
				" duration refreshed"
			)

		# --------------------------------------
		# Add stack
		# --------------------------------------

		if existing.can_stack:

			var old_stacks: int = existing.stacks

			existing.stacks = min(
				existing.stacks + effect.stacks,
				existing.max_stacks
			)

			var added_stacks: int = existing.stacks - old_stacks

			if added_stacks > 0:
				existing.apply_stack(
					self,
					added_stacks
				)

			print(
				existing.effect_name,
				" stacked to ",
				existing.stacks
			)

		trigger_passive_event(
			"status_applied",
			{
				"status": existing
			}
		)

		status_changed.emit(self)

		GameEvents.status_changed.emit(
			self,
			get_all_enemies()
		)

		return


	# ==========================================
	# First application
	# ==========================================

	var new_effect: StatusEffect = effect.duplicate()

	new_effect.stacks = 1

	status_effects.append(
		new_effect
	)

	new_effect.apply_stack(
		self,
		1
	)

	trigger_passive_event(
		"status_applied",
		{
			"status":new_effect
		}
	)

	print(
		new_effect.effect_name,
		" applied to ",
		name
	)

	status_changed.emit(self)

	GameEvents.status_changed.emit(
		self,
		get_all_enemies()
	)


func remove_status_effect(
	effect:StatusEffect
):

	if effect == null:
		return

	if not status_effects.has(effect):
		return

	# ==========================================
	# Remove stat modifiers
	# ==========================================

	effect.remove(self)

	# ==========================================
	# Passive event
	# ==========================================

	trigger_passive_event(
		"status_removed",
		{
			"status": effect
		}
	)

	# ==========================================
	# Remove
	# ==========================================

	status_effects.erase(
		effect
	)

	status_changed.emit(
		self
	)
	
	GameEvents.status_changed.emit(
		self,
		get_all_enemies()
	)

	print(
		effect.effect_name,
		" expired on ",
		name
	)


func clear_status_effects() -> void:

	for effect in status_effects.duplicate():

		if effect == null:
			continue

		if not is_instance_valid(effect):
			continue

		remove_status_effect(effect)


func tick_status_effects():

	for effect in status_effects.duplicate():

		if effect == null:
			continue

		if not is_instance_valid(effect):
			continue

		effect.duration -= 1

		print(
			name,
			" ",
			effect.effect_name,
			" duration:",
			effect.duration
		)

		if effect.duration <= 0:

			remove_status_effect(
				effect
			)


# ==================================================
# STATS
# ==================================================


func get_attack() -> int:

	var value = base_attack + attack_modifier
	
	for slot in gene_slots:

		for gene in gene_slots[slot]:

			value += gene.attack_bonus

	for passive in passive_effects:

		value = passive.modify_attack(
			self,
			value
		)


	return value


func get_max_hp() -> int:

	var value = base_hp

	for slot in gene_slots:

		for gene in gene_slots[slot]:

			value += gene.hp_bonus

	for passive in passive_effects:

		if passive.has_method("modify_max_hp"):

			value = passive.modify_max_hp(
				self,
				value
			)

	return value


func get_speed() -> int:

	var value = base_speed + speed_modifier

	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.speed_bonus

	for passive in passive_effects:

		value = passive.modify_speed(
			self,
			value
		)

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

			value += gene.accuracy_bonus

	for passive in passive_effects:

		value = passive.modify_accuracy(
			self,
			value
		)


	return value


func get_evasion() -> int:
	
	var value = base_evasion + evasion_modifier
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.evasion_bonus

	for passive in passive_effects:

		value = passive.modify_evasion(
			self,
			value
		)

	return clamp(value, 0, 90)


func get_armor() -> int:

	var value = base_armor + defense_modifier
	
	for slot in gene_slots:
		for gene in gene_slots[slot]:
			value += gene.armor_bonus
			
	for passive in passive_effects:

		value = passive.modify_armor(
			self,
			value
		)

	return value


func get_critical_chance() -> int:

	var chance: int = critical_modifier

	print(
		"CRIT CHECK:",
		name,
		" base:",
		critical_modifier
	)

	for slot in gene_slots:

		for gene in gene_slots[slot]:

			if gene == null:
				continue

			print(
				"  Gene:",
				gene.gene_name,
				" Crit Bonus:",
				gene.critical_bonus
			)

			chance += gene.critical_bonus

	for passive in passive_effects:

		chance = passive.modify_critical_chance(
			self,
			chance
		)

	print(
		"  FINAL CRIT:",
		chance
	)

	return chance


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
	
	var final_chance = clamp(chance,10,100)

	print(
		name,
		" hit chance:",
		final_chance
	)

	return final_chance


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

# 60% damage reduction
var protect_reduction := 0.6


func take_damage(
	amount:int,
	attacker:AnimalBase = null,
	is_status_damage:bool = false
):

	print("")
	print("TAKE DAMAGE")
	print(name)
	print("Instance:", get_instance_id())
	print("HP before:", hp)

	var damage_data = {
		"amount": amount,
		"attacker": attacker
	}

	amount = damage_data.amount


	# ==========================================
	# Protect first
	# ==========================================

	if not is_status_damage and is_protecting:

		amount = int(
			amount * (1.0 - protect_reduction)
		)

		print(
			name,
			" blocked damage with protect"
		)


	# ==========================================
	# Passive damage modifiers second
	# ==========================================

	damage_data.amount = amount

	trigger_passive_event(
		"before_damage",
		damage_data
	)

	if damage_data.has("messages"):

		for message in damage_data.messages:

			BattleLog.add_message(
				message
			)

	amount = damage_data.amount


	# ==========================================
	# Armor last
	# ==========================================

	if not is_status_damage:

		amount = calculate_damage_taken(amount)

	amount = max(
		1,
		amount
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

	BattleLog.add_message(
		"%s took %d damage!" % [
			name,
			amount
		]
	)

	trigger_passive_event(
		"after_damage",
		{
			"amount": amount,
			"attacker": attacker
		}
	)

	GameEvents.hp_changed.emit(
		self,
		hp,
		get_max_hp()
	)

	#hp_changed.emit(hp)

	if hp <= 0:
		die()

	print("HP after:", hp)


func take_status_damage(
	amount:int
):

	amount = max(1, amount)

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
		" status damage. HP:",
		hp
	)

	print(
		"STATUS HP EVENT:",
		name,
		" ID:",
		get_instance_id(),
		" HP:",
		hp
	)

	GameEvents.hp_changed.emit(
		self,
		hp,
		get_max_hp()
	)

	#hp_changed.emit(hp)

	if hp <= 0:
		die()


func die():

	if hp > 0:
		return

	trigger_passive_event(
		"death"
	)

	animal_died.emit()

	print(
		name,
		" has been defeated"
	)


func is_alive() -> bool:
	return hp > 0
	
	
func heal(amount:int):

	var heal_data = {
		"amount": amount
	}

	trigger_passive_event(
		"before_heal",
		heal_data
	)

	amount = heal_data.amount

	hp += amount

	hp = clamp(
		hp,
		0,
		get_max_hp()
	)

	trigger_passive_event(
		"after_heal",
		{
			"amount": amount
		}
	)

	GameEvents.hp_changed.emit(
		self,
		hp,
		get_max_hp()
	)

	#hp_changed.emit(hp)

	if hp <= 0:
		die()


func calculate_move_damage(move:MoveResource) -> int:

	var damage := 0

	match move.damage_type:

		MoveResource.DamageType.PHYSICAL:
			damage = get_attack()

		MoveResource.DamageType.SPECIAL:
			damage = get_attack()

		MoveResource.DamageType.TRUE:
			damage = 0

	damage += move.power
	
	damage = int(
		damage * move.damage_multiplier
	)

	for passive in passive_effects:

		damage = passive.modify_damage_dealt(
			self,
			damage
		)

	return int(damage)


func calculate_damage_taken(amount: int) -> int:

	for passive in passive_effects:

		amount = passive.modify_damage_taken(
			self,
			amount
		)

	var armor = get_armor()

	var reduction = armor * 0.01

	var final_damage = amount * (1.0 - reduction)

	return max(
		1,
		int(final_damage)
	)


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

	BattleLog.add_message(
		"%s is protecting itself!" % name
	)


func clear_protect():
	is_protecting = false


# ==================================================
# PASSIVE EFFECTS
# ==================================================


func trigger_passive_event(
	event_name: String,
	data = null
):

	if data == null:
		data = {}

	for passive in passive_effects:

		if passive == null:
			continue

		match event_name:

			"battle_start":

				passive.on_battle_start(
					self
				)

			"battle_end":

				passive.on_battle_end(
					self
				)

			"turn_start":

				passive.on_turn_start(
					self
				)

			"turn_end":

				passive.on_turn_end(
					self
				)

			"before_attack":

				passive.on_before_attack(
					self,
					data
				)

			"after_attack":

				passive.on_after_attack(
					self,
					data
				)

			"attack_missed":

				passive.on_attack_missed(
					self,
					data
				)

			"critical_hit":

				passive.on_critical_hit(
					self,
					data
				)

			"before_damage":

				passive.on_before_damage(
					self,
					data
				)

			"after_damage":


				passive.on_after_damage(
					self,
					data
				)

			"before_heal":

				passive.on_before_heal(
					self,
					data
				)

			"after_heal":

				passive.on_after_heal(
					self,
					data
				)

			"status_applied":

				passive.on_apply_status(
					self,
					data
				)

			"status_removed":

				passive.on_remove_status(
					self,
					data
				)

			"status_received":

				passive.on_status_received(
					self,
					data
				)

			"death":

				passive.on_death(
					self
				)

			"kill":

				passive.on_kill(
					self,
					data
				)


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
	passive_effects.clear()
	
	#learned_moves.clear()
	basic_moves.clear()
	gene_moves.clear()
	selected_moves.clear()

	clear_status_effects()
	
	for slot in gene_slots:
		gene_slots[slot].clear()
		
	speed_modifier = 0
	attack_modifier = 0
	defense_modifier = 0
	accuracy_modifier = 0
	evasion_modifier = 0
	armor_modifier = 0

	is_protecting = false

	if run_manager:
		hp = run_manager.player_hp
	else:
		hp = base_hp

	setup_basic_moves()

	for gene in build.genes:
		add_gene(gene)

	for move in build.moves:
		add_move(move)
