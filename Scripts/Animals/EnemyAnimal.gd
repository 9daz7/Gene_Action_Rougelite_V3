extends AnimalBase
class_name EnemyAnimal


@export var enemy_data: EnemyResource

@onready var enemy_sprite: Sprite2D = $EnemySprite

#var protect_count := 0

func start_battle():

	print("Enemy ready")

	if enemy_data == null:
		return

	name = enemy_data.enemy_name

	print("Loaded enemy:", enemy_data.enemy_name)

	load_animal_stats(enemy_data)

	hp = get_max_hp()

	load_genes(enemy_data.starting_genes)

	selected_moves.clear()

	for move in enemy_data.moves:
		if move == null:
			continue

		add_move(move)

	if enemy_data.sprite:
		enemy_sprite.texture = enemy_data.sprite
		print("SPRITE LOADED: ", enemy_data.sprite.resource_path)
	else:
		print("NO SPRITE ASSIGNED TO: ", enemy_data.enemy_name)


func take_damage(
	amount: int,
	attacker: AnimalBase = null,
	is_status_damage: bool = false,
	move: MoveResource = null
):
	super.take_damage(
		amount,
		attacker,
		is_status_damage,
		move
	)

	if attacker == null:
		return

	if not is_alive():
		return

	var controller := get_node_or_null(
		"ActionEnemyController"
	)

	if controller == null:
		return

	if controller.has_method("alert_to_attacker"):
		controller.alert_to_attacker(attacker)


func get_drop_gene() -> GeneResource:

	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
