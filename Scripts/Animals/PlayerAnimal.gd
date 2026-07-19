extends AnimalBase
class_name PlayerAnimal


func start_battle():
	print("Player ready")
	
	setup_basic_moves()
	
	
func setup_player_hp(manager):
	
	run_manager = manager
	
	base_hp = run_manager.max_hp
	hp = run_manager.player_hp

	print(
		"Loaded player HP:",
		hp,
		"/",
		base_hp
	)
	
	
func load_build(build:AnimalBuildResource):

	if build == null:
		print("No build")
		return

	name = build.animal_name

	print("==== LOADING BUILD ====")
	print("Animal:", name)
	print("HP:", base_hp)
	print("Attack:", base_attack)
	print("Speed:", base_speed)
	
	animal_resource = build.animal
	
# Load base animal stats
	if animal_resource:

		base_hp = animal_resource.base_hp
		base_attack = animal_resource.base_attack
		base_speed = animal_resource.base_speed

		print(
			"Base animal:",
			animal_resource.animal_name
		)

	else:
		print("ERROR: No animal resource assigned")

	print(
		"Animal:",
		name
	)

	print(
		"HP:",
		base_hp
	)

	print(
		"Attack:",
		base_attack
	)

	print(
		"Speed:",
		base_speed
	)

	# Reset old data
	equipped_genes.clear()
	learned_moves.clear()

	# Setup universal moves
	setup_basic_moves()

	# Apply genes
	for gene in build.genes:
		add_gene(gene)

	# Add chosen gene moves
	for move in build.moves:
		add_move(move)

	print(
		"Loaded genes:",
		equipped_genes.size()
	)

	print(
		"Loaded moves:",
		learned_moves.size()
	)
	
	
func take_damage(amount:int):
	super.take_damage(amount)
	if run_manager:
		run_manager.player_hp = hp

		print(
			"Saved run HP:",
			run_manager.player_hp
		)
