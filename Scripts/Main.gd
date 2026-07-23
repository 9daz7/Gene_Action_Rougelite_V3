extends Node


@onready var managers = $Managers

@onready var battle_manager: BattleManager = $Managers/BattleManager
@onready var turn_manager: TurnManager = $Managers/TurnManager
@onready var run_manager: RunManager = $Managers/RunManager
@onready var battle_spawner = $Managers/BattleSpawner

@onready var battle_root: Node = $World/BattleRoot

#@onready var battle_manager = $Managers/BattleManager
#@onready var run_manager = $Managers/RunManager
@onready var map_manager = $Managers/MapManager
@onready var ui_manager = $Managers/UIManager
@onready var gene_database = $Managers/GeneDatabase
@onready var reward_manager = $Managers/RewardManager
@onready var save_manager = $Managers/SaveManager


@onready var map_ui = $UI/MapUI
@onready var lab_hub = $UI/LabHub
@onready var room_manager = $Managers/RoomManager


var current_room: RoomData = null


func _ready():
	print("THIS IS THE CURRENT MAIN SCRIPT")

	battle_manager.initialize(
	run_manager,
	turn_manager,
	battle_root,
	battle_spawner
)

	gene_database.load_genes()
	
	save_manager.load_game(
		run_manager,
		gene_database
	)
	
	run_manager.initialize_starting_collection(gene_database)

	map_ui.hide()
	lab_hub.hide()
	
	lab_hub.start_run_requested.connect(start_run)

	map_ui.room_entered.connect(enter_room)

	battle_manager.battle_won.connect(_on_battle_won)
	battle_manager.battle_lost.connect(_on_battle_lost)

	lab_hub.animal_creation.build_confirmed.connect(
		_on_build_confirmed
	)

	open_lab_hub()


func open_lab_hub():
	print("Opening Lab Hub")
	
	map_ui.hide()
	
	lab_hub.open()
	
	print("LabHub visible:", lab_hub.visible)


#func start_gene_selection():
	##var gene_choices = run_manager.get_random_owned_genes(5)
#
	#print("Opening gene loadout")
	#
	#print("Owned genes:")
#
	#for gene in run_manager.gene_collection:
		#print(
			#gene.gene_name,
			#" | ",
			#gene.get_rarity_name()
		#)
#
	#gene_loadout.open(run_manager.gene_collection)


func _on_build_confirmed(build):

	print(
		"Build confirmed:",
		build.animal_name
	)

	run_manager.set_animal_build(build)
	

func start_run():
	print("======================")
	print("MAIN START_RUN CALLED")
	print("======================")

	if run_manager.current_animal_build == null:
		print("ERROR: No animal build exists")
		return

	print(
		"Starting animal:",
		run_manager.current_animal_build.animal_name
	)

	map_manager.generate_map()

	lab_hub.hide()
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
	print("MAIN RECEIVED BATTLE WON")
	print("Critical flag:", battle_manager.critical_experiment)
	print("Battle type:", battle_manager.current_battle_type)
	#print("Battle won against:", enemy.enemy_data.enemy_name)
	
	# boss victory
	if battle_manager.current_battle_type == RoomData.RoomType.BOSS:
		print("BOSS DEFEATED")
		await get_tree().process_frame
		open_victory_screen()
		return
	
	# critical experiment
	if battle_manager.critical_experiment:
		print("Skipping rewards: critical experiment")
		return
		
	# normal rewards
	if enemy == null:
		print("No enemy supplied for reward")
		return
	
	if enemy.enemy_data == null:
		print("Enemy has no enemy_data")
		return

	print(
		"Battle won against:",
		enemy.enemy_data.enemy_name
	)
	#

	var rewards = reward_manager.generate_rewards(enemy)
	
	save_manager.gold += rewards.gold
	save_manager.save_game(run_manager)
	
	print("Gold:", rewards.gold)
	print("Resources:", rewards.resources)

	#if rewards.gene_choices.size() > 0:
		#print("Gene choices:")
#
		#for gene in rewards.gene_choices:
			#print(gene.gene_name)
#
	#print(
		#"Mutagen choices:",
		#rewards.mutagen_choices
	#)

	room_manager.open_reward(rewards)
	

func open_victory_screen():

	print("===================")
	print("GAME COMPLETE")
	print("===================")

	await get_tree().create_timer(3.0).timeout

	current_room = null
	
	run_manager.reset_run()
	
	map_ui.hide()
	
	open_lab_hub()
	

func _on_battle_lost():
	print("Run failed")
	
	current_room = null

	run_manager.reset_run()
	
	map_ui.hide()
	
	open_lab_hub()


func return_to_map():
	print("Returning to map")
	
	lab_hub.hide()

	map_ui.display_map(
		map_manager.current_map
	)
	
	map_ui.show()
