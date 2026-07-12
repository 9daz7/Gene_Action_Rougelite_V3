extends Node


@onready var managers = $Managers

@onready var battle_manager = $Managers/BattleManager
@onready var run_manager = $Managers/RunManager
@onready var map_manager = $Managers/MapManager
@onready var ui_manager = $Managers/UIManager
@onready var gene_database = $Managers/GeneDatabase
@onready var reward_manager = $Managers/RewardManager


@onready var map_ui = $UI/MapUI
@onready var gene_selection = $UI/GeneSelectionScreen
@onready var room_manager = $Managers/RoomManager


var current_room: RoomData = null


func _ready():
	print("THIS IS THE CURRENT MAIN SCRIPT")

	gene_database.load_genes()

	gene_selection.genes_selected.connect(start_run)

	map_ui.hide()
	gene_selection.hide()

	map_ui.room_entered.connect(enter_room)

	battle_manager.battle_won.connect(_on_battle_won)
	battle_manager.battle_lost.connect(_on_battle_lost)

	start_new_run()


func start_new_run():
	start_gene_selection()


func start_gene_selection():
	var gene_choices = gene_database.get_random_genes(5)

	print("Starting gene choices:")

	for gene in gene_choices:
		print(
			gene.gene_name,
			" | ",
			gene.get_rarity_name()
		)

	gene_selection.open(gene_choices)


func start_run(selected_genes: Array[GeneResource]):
	print("======================")
	print("MAIN START_RUN CALLED")
	print("======================")

	print("START RUN ENTERED")

	print("Starting genes:")

	for gene in selected_genes:
		print(gene.gene_name)


	print("Checking RunManager")

	if run_manager == null:
		print("ERROR: RunManager is NULL")
		return


	print("RunManager found:", run_manager)


	print("Calling setup_run")

	run_manager.setup_run(selected_genes)


	print("setup_run finished")


	print("Calling map generation")

	map_manager.generate_map()


	print("Map generation finished")


	map_ui.show()

	map_ui.display_map(
		map_manager.current_map
	)


	print("Map displayed")
	
func enter_room(room):

	current_room = room

	print("MAIN ENTERING ROOM:", room.room_type)

	map_ui.hide()

	room_manager.enter_room(room)


func _on_battle_won(enemy):
	print("Battle won!")

	var rewards = reward_manager.generate_rewards(
		current_room.room_type
	)

	print("Gold:", rewards.gold)

	print("Resources:", rewards.resources)


	if rewards.discovered_gene.size() > 0:
		print("Gene choices:")

		for gene in rewards.discovered_gene:
			print(
				gene.gene_name
			)


	print(
		"Mutagen choices:",
		rewards.mutagen_choices
	)

	return_to_map()


func _on_battle_lost():
	print("Run failed")

	return_to_map()


func return_to_map():
	print("Returning to map")

	map_ui.display_map(
		map_manager.current_map
	)
	
	map_ui.show()
