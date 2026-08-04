extends AnimalBase
class_name EnemyAnimal


@export var enemy_data: EnemyResource

var enemy_index:int = 0

var last_move: MoveResource = null
#var protect_count := 0

func start_battle():

	print("Enemy ready")

	if enemy_data == null:
		return

	name = enemy_data.enemy_name

	print("Loaded enemy:", enemy_data.enemy_name)

	load_animal_stats(enemy_data)

	hp = base_hp

	load_genes(enemy_data.starting_genes)

	selected_moves.clear()

	for move in enemy_data.moves:
		if move == null:
			continue

		add_move(move)


func get_all_enemies() -> Array:
	return [turn_manager.player]


func get_all_allies() -> Array:
	return turn_manager.enemies


func choose_action(player:AnimalBase) -> MoveResource:

	var moves = get_battle_moves()

	if moves.is_empty():
		return null


	var chosen_move = get_best_move(player, moves)

	if chosen_move == null:

		print(
			name,
			" has no valid move"
		)

		return null

	print(name, " chose ", chosen_move.move_name)

	last_move = chosen_move

	return chosen_move

	#var chosen_move: MoveResource
	#
	#match enemy_data.ai_type:
#
		#EnemyResource.AIType.BASIC:
			#chosen_move = choose_basic_move(moves)
#
#
		#EnemyResource.AIType.AGGRESSIVE:
			#chosen_move = choose_aggressive_move(moves)
#
#
		#EnemyResource.AIType.DEFENSIVE:
			#chosen_move = choose_defensive_move(moves)
#
#
		#EnemyResource.AIType.TACTICAL:
			#chosen_move = choose_tactical_move(moves, player)
#
#
		#_:
			#chosen_move = get_best_move(player,moves)
#
	#print(
		#name,
		#" chose ",
		#chosen_move.move_name
	#)
#
	#last_move = chosen_move
#
	#return chosen_move


func get_best_move(
	player:AnimalBase,
	moves:Array
) -> MoveResource:

	var best_move:MoveResource = null
	var best_score := -999

	for move in moves:

		var score = evaluate_move(
			move,
			player
		)

		print(
			name,
			" evaluated ",
			move.move_name,
			" score:",
			score
		)

		if score > best_score:
			best_score = score
			best_move = move

	return best_move


func evaluate_move(
	move:MoveResource,
	player:AnimalBase
) -> int:

	var score := 0

	# ==================================
	# Priority
	# ==================================

	score += move.priority * 5

	# ==================================
	# Damage moves
	# ==================================

	if move.effect_type == MoveResource.MoveEffectType.DAMAGE:
		
		score += move.power
		
		score += (
			10 
			* enemy_data.aggression
		)

	# ==================================
	# Hybrid moves
	# ==================================

	if move.effect_type == MoveResource.MoveEffectType.HYBRID:
		
		score += move.power
		
		score += (
			15
			* enemy_data.aggression
		)

		score += (
			10
			* enemy_data.status_preference
		)

	# ==================================
	# Protect
	# ==================================

	if move.effect_type == MoveResource.MoveEffectType.PROTECT:

		var hp_percent = float(hp) / float(get_max_hp())

		# Base defensive preference
		score += (
			10 
			* enemy_data.defense
		)


		# Protect is better when damaged

		if hp_percent < 0.25:

			score += 25

		elif hp_percent < 0.4:

			score += 10

		else:

			score -= 40


		# Prevent Protect spam

		if last_move == move:

			score -= 100
		
		## Protect becomes valuable when hurt
		#if hp_percent < 0.25:
			#score += 15
		#elif hp_percent < 0.4:
			#score += 5
		#else:
			#score -= 50
#
		## prevent repeated protect
		#if last_move == move:
			#score -= 90


# ==================================
# Battle Advantage
# ==================================

	var enemy_hp_percent = float(hp) / float(get_max_hp())
	var player_hp_percent = float(player.hp) / float(player.get_max_hp())


	# If winning, attack more

	if enemy_hp_percent > player_hp_percent:

		if move.effect_type == MoveResource.MoveEffectType.DAMAGE:
			score += 15


	# If losing, consider survival

	if enemy_hp_percent < player_hp_percent:

		if move.effect_type == MoveResource.MoveEffectType.PROTECT:
			score += 10


	# ==================================
	# Status effects
	# ==================================

	if move.effect_type == MoveResource.MoveEffectType.STATUS:
		
		score += (
			25
			* enemy_data.status_preference
		)


	# ==================================
	# Finishing move
	# ==================================

	if move.effect_type == MoveResource.MoveEffectType.DAMAGE:

		if player.hp <= move.power:
			score += 50

	return score


#func choose_basic_move(moves):
#
	#return moves.pick_random()
#
#
#func choose_aggressive_move(moves):
#
	#var best_move = moves[0]
#
#
	#for move in moves:
#
		#if move.power > best_move.power:
			#best_move = move
#
#
	#return best_move
#
#
#func choose_defensive_move(moves):
#
	#if hp <= get_max_hp() * 0.4:
#
		#for move in moves:
#
			#if move.effect_type == MoveResource.MoveEffectType.PROTECT:
				#return move
#
#
	#return moves.pick_random()
#
#
#func choose_tactical_move(
	#moves,
	#player
#):
#
	#if hp <= get_max_hp() * 0.3:
#
		#for move in moves:
#
			#if move.effect_type == MoveResource.MoveEffectType.PROTECT:
				#return move
#
#
	#for move in moves:
#
		#if move.effect_type == MoveResource.MoveEffectType.STATUS:
			#return move
#
#
	#return choose_aggressive_move(moves)


func get_drop_gene() -> GeneResource:

	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
