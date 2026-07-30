extends AnimalBase
class_name EnemyAnimal


@export var enemy_data: EnemyResource


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


func choose_action(player:AnimalBase) -> MoveResource:

	var moves = get_battle_moves()

	if moves.is_empty():
		return null

	match enemy_data.ai_type:
		
		EnemyResource.AIType.BASIC:
			return choose_basic_move(moves)

		EnemyResource.AIType.AGGRESSIVE:
			return choose_aggressive_move(moves)


		EnemyResource.AIType.DEFENSIVE:
			return choose_defensive_move(moves)


		EnemyResource.AIType.TACTICAL:
			return choose_tactical_move(moves, player)


	return moves[0]


func choose_basic_move(moves):

	return moves.pick_random()


func choose_aggressive_move(moves):

	var best_move = moves[0]


	for move in moves:

		if move.power > best_move.power:
			best_move = move


	return best_move


func choose_defensive_move(moves):

	if hp <= get_max_hp() * 0.4:

		for move in moves:

			if move.effect_type == MoveResource.MoveEffectType.PROTECT:
				return move


	return moves.pick_random()


func choose_tactical_move(
	moves,
	player
):

	if hp <= get_max_hp() * 0.3:

		for move in moves:

			if move.effect_type == MoveResource.MoveEffectType.PROTECT:
				return move


	for move in moves:

		if move.effect_type == MoveResource.MoveEffectType.STATUS:
			return move


	return choose_aggressive_move(moves)


func get_drop_gene() -> GeneResource:

	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
