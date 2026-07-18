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

	# Base animal stats
	base_hp = build.base_hp
	base_attack = build.base_attack
	base_speed = build.base_speed

	# Load genes
	for gene in build.selected_genes:
		add_gene(gene)

	# Load selected gene moves
	for move in build.selected_moves:
		add_move(move)

	print(
		"Loaded build:",
		name
	)
	
	
	

func take_damage(amount:int):
	super.take_damage(amount)
	if run_manager:
		run_manager.player_hp = hp

		print(
			"Saved run HP:",
			run_manager.player_hp
		)
