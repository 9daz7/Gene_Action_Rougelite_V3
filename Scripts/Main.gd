extends Node


# ==================================================
# Managers
# ==================================================

@onready var managers = $Managers

@onready var battle_manager: BattleManager = $Managers/BattleManager
@onready var turn_manager: TurnManager = $Managers/TurnManager
@onready var run_manager: RunManager = $Managers/RunManager
@onready var battle_spawner = $Managers/BattleSpawner

@onready var mutagen_database: MutagenDatabase = $Managers/MutagenDatabase
@onready var run_mutagen_manager: RunMutagenManager = $Managers/RunMutagenManager

@onready var battle_root: Node = $World/BattleRoot

#@onready var battle_manager = $Managers/BattleManager
#@onready var run_manager = $Managers/RunManager
@onready var map_manager = $Managers/MapManager
@onready var ui_manager = $Managers/UIManager
@onready var gene_database = $Managers/GeneDatabase
@onready var reward_manager = $Managers/RewardManager
@onready var save_manager = $Managers/SaveManager


# ==================================================
# World
# ==================================================

@onready var hub_world: HubWorld = $World/HubWorld

@onready var map_ui = $UI/MapUI
@onready var room_manager = $Managers/RoomManager

const LAB_HUB_SCENE = preload(
	"res://Scenes/LabHub/LabHub.tscn"
)


# ==================================================
# State
# ==================================================

var lab_hub: LabHub = null


func _ready():

	if not GameEvents.battle_won.is_connected(
		_on_battle_won
	):
		GameEvents.battle_won.connect(
			_on_battle_won
		)

	if not GameEvents.battle_lost.is_connected(
		_on_battle_lost
	):
		GameEvents.battle_lost.connect(
			_on_battle_lost
		)

	print("THIS IS THE CURRENT MAIN SCRIPT")

	battle_manager.initialize(
		run_manager,
		turn_manager,
		battle_root,
		battle_spawner
	)

	gene_database.load_genes()

	save_manager.load_game(
		PermanentProgressionManager,
		gene_database
	)

	run_manager.initialize_starting_collection(
		gene_database
	)

	run_manager.load_room_pools()

	mutagen_database.initialize()

	_create_lab_hub()


	# ==================================================
	# Hub World Setup
	# ==================================================

	hub_world.setup(
		run_manager,
		gene_database
	)

	if not hub_world.animal_lab_requested.is_connected(
		_on_animal_lab_requested
	):
		hub_world.animal_lab_requested.connect(
			_on_animal_lab_requested
		)

	# ==================================================
	# Map Setup
	# ==================================================

	map_ui.hide()

	if not GameEvents.room_entered.is_connected(
		_on_room_entered
	):

		GameEvents.room_entered.connect(
			_on_room_entered
		)

	print("Opening Hub World")

	hub_world.open()

	if is_instance_valid(lab_hub):
		lab_hub.hide()


# ==================================================
# Hub World
# ==================================================

func _create_lab_hub() -> void:

	if is_instance_valid(lab_hub):
		return

	lab_hub = LAB_HUB_SCENE.instantiate()

	$UI.add_child(lab_hub)

	lab_hub.setup(
		run_manager,
		gene_database
	)

	if not lab_hub.build_confirmed.is_connected(
		_on_hub_build_confirmed
	):

		lab_hub.build_confirmed.connect(
			_on_hub_build_confirmed
		)

	if not lab_hub.start_run_requested.is_connected(
		_on_hub_start_run_requested
	):

		lab_hub.start_run_requested.connect(
			_on_hub_start_run_requested
		)

	#lab_hub.lab_closed.connect(
		#_on_lab_hub_closed
	#)

	lab_hub.hide()

	print("LabHub created")


func _on_hub_build_confirmed(
	build: AnimalBuildResource
) -> void:

	print(
		"MAIN RECEIVED BUILD:",
		build.animal_name
	)

	run_manager.set_animal_build(build)


func _on_hub_start_run_requested() -> void:

	print("MAIN RECEIVED RUN REQUEST")

	start_run()


func open_lab_hub() -> void:

	print("================================")
	print("OPENING LAB HUB")
	print("================================")

	map_manager.disable_scanner()
	map_ui.close_map()

	hub_world.close()

	if not is_instance_valid(lab_hub):
		push_error("LabHub instance is missing.")
		return

	lab_hub.show()

	print("LabHub visible:",
		lab_hub.visible
	)


func _on_lab_hub_closed() -> void:

	print("MAIN: LabHub closed")

	lab_hub.hide()

	hub_world.open()


func _on_animal_lab_requested() -> void:

	if run_manager.run_active:
		print("Ignoring Animal Lab request because a run is active")
		return

	print("MAIN: Animal Lab requested")

	open_lab_hub()


#func _on_build_confirmed(build):
#
	#print(
		#"Build confirmed:",
		#build.animal_name
	#)
#
	#run_manager.set_animal_build(build)


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

	run_manager.start_run()

	GameEvents.run_started.emit()

	hub_world.close()
	lab_hub.hide()

	print("================================")
	print("TESTING NEW ROOM RESOURCE SYSTEM")
	print("================================")

	run_manager.create_run_map()

	# ==================================================
	# Enable Scanner
	# ==================================================

	map_manager.enable_scanner()

	map_ui.close_map()


func _on_room_entered(room: RoomData) -> void:

	#current_room = room

	print(
		"MAIN RECEIVED ROOM ENTERED:",
		room.room_type
	)

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

	# roaming battles
	if battle_manager.roaming_battle:
		print(
			"MAIN: Roaming battle victory. "
			+ "Skipping normal room rewards."
		)
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


	var rewards = reward_manager.generate_rewards(enemy)

	run_manager.add_gold(rewards.gold)

	print("Resources:", rewards.resources)

	room_manager.open_reward(rewards)


func open_victory_screen():

	print("===================")
	print("GAME COMPLETE")
	print("===================")

	await get_tree().create_timer(0.0).timeout

	map_manager.disable_scanner()
	map_ui.close_map()

	var enemy_reward := PermanentProgressionManager.reward_enemy_defeats(
		run_manager.enemies_defeated
	)

	print(
		"Permanent progression reward:",
		enemy_reward
	)

	run_manager.reset_run()

	open_lab_hub()


func _on_battle_lost():

	print("Run failed")

	map_manager.disable_scanner()

	var enemy_reward := PermanentProgressionManager.reward_enemy_defeats(
		run_manager.enemies_defeated
	)

	print(
		"Permanent progression reward:",
		enemy_reward
	)

	run_manager.reset_run()

	map_ui.hide()

	open_lab_hub()


func finish_run():

	var enemy_reward := PermanentProgressionManager.reward_enemy_defeats(
		run_manager.enemies_defeated
	)

	print(
		"Permanent progression reward:",
		enemy_reward
	)

	run_manager.reset_run()


func return_to_map() -> void:

	print("Returning to Scanner")

	if not map_manager.scanner_enabled:

		return

	map_ui.open_map()
