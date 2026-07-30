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
		if move:
			add_move(move)


func choose_action(player:AnimalBase) -> MoveResource:

	var moves = get_battle_moves()

	if moves.is_empty():
		return null

	return moves[0]


func get_drop_gene() -> GeneResource:

	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
