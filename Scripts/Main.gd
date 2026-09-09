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

@onready var potion_database: PotionDatabase = $Managers/PotionDatabase

@onready var battle_root: Node = $World/BattleRoot
@onready var map_root: Node = $World/MapRoot

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

const ABANDONED_LAB_UI_SCENE = preload(
	"res://Scenes/Rooms/AbandonedLab_UI.tscn"
)

const BETWEEN_WORLD_LAB_DATA = preload(
	"res://Data/Labs/BetweenWorldLab.tres"
)


# ==================================================
# State
# ==================================================

var lab_hub: LabHub = null
var between_world_lab_ui: AbandonedLab_UI = null
var returning_to_hub_after_battle: bool = false


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

	if not battle_manager.battle_cleanup_finished.is_connected(
		_on_battle_cleanup_finished
	):
		battle_manager.battle_cleanup_finished.connect(
			_on_battle_cleanup_finished
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


func open_between_world_lab() -> void:

	print("================================")
	print("OPENING BETWEEN-WORLD LAB")
	print("================================")

	# ==================================================
	# Prevent duplicate UI
	# ==================================================

	if is_instance_valid(between_world_lab_ui):

		print(
			"Between-world Lab is already open."
		)

		return

	# ==================================================
	# Validate LabResource
	# ==================================================

	if BETWEEN_WORLD_LAB_DATA == null:

		push_error(
			"Main: Between-world LabResource is missing."
		)

		return

	# ==================================================
	# Create temporary room state
	# ==================================================

	var temporary_room := RoomResource.new()

	temporary_room.room_name = "Between-World Lab"

	temporary_room.room_type = (
		RoomResource.RoomType.LAB
	)

	# --------------------------------------------------
	# Prevent Critical Lab battle
	# --------------------------------------------------

	temporary_room.lab_battle_completed = true

	# --------------------------------------------------
	# Fresh state for this Lab visit
	# --------------------------------------------------

	temporary_room.lab_mutagen_editing_completed = false
	temporary_room.lab_healing_used = false
	temporary_room.pending_lab_mutagen_reward = null

	# Use the dedicated Between-World LabResource.
	temporary_room.lab_data = (
		BETWEEN_WORLD_LAB_DATA
	)

	# ==================================================
	# Create Lab UI
	# ==================================================

	between_world_lab_ui = (
		ABANDONED_LAB_UI_SCENE.instantiate()
		as AbandonedLab_UI
	)

	if between_world_lab_ui == null:

		push_error(
			"Main: Failed to create Between-World Lab UI."
		)

		return

	$UI.add_child(
		between_world_lab_ui
	)

	between_world_lab_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# ==================================================
	# Connect Finish
	# ==================================================

	if not between_world_lab_ui.lab_finished.is_connected(
		_on_between_world_lab_finished
	):

		between_world_lab_ui.lab_finished.connect(
			_on_between_world_lab_finished
		)

	# ==================================================
	# Open
	# ==================================================

	between_world_lab_ui.open(
		temporary_room.lab_data,
		battle_manager,
		temporary_room,
		true
	)

	print(
		"Between-World Lab opened."
	)


func _on_between_world_lab_finished() -> void:

	print("================================")
	print("BETWEEN-WORLD LAB FINISHED")
	print("================================")

	if is_instance_valid(
		between_world_lab_ui
	):

		between_world_lab_ui.close()
		between_world_lab_ui.queue_free()

	between_world_lab_ui = null

	# ==================================================
	# Transition is finished
	# ==================================================

	run_manager.world_transition_pending = false

	print(
		"Starting World:",
		run_manager.current_world
	)

	print(
		"Creating new run map..."
	)


	# ==================================================
	# Generate next world
	# ==================================================

	run_manager.create_run_map()

	print(
		"create_run_map() returned."
	)

	print(
		"Current run map:",
		run_manager.current_run_map
	)

	if run_manager.current_run_map == null:

		push_error(
			"MAIN: World map generation failed."
		)

		return

	print(
		"World map exists."
	)

	print(
		"Layer count:",
		run_manager.current_run_map.layers.size()
	)

	print(
		"Node count:",
		run_manager.current_run_map.all_nodes.size()
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

	print("HubWorld visible after close:", hub_world.visible)
	print("HubWorld process mode after close:", hub_world.process_mode)

	var hub_player := hub_world.get_node_or_null("HubPlayer")

	if hub_player != null:

		print(
			"HubPlayer visible after close:",
			hub_player.visible
		)

		print(
			"HubPlayer process mode after close:",
			hub_player.process_mode
		)

	# ==================================================
	# Enable Run Worlds
	# ==================================================

	if map_root != null:
		map_root.show()
		map_root.process_mode = Node.PROCESS_MODE_INHERIT

	if battle_root != null:
		battle_root.show()
		battle_root.process_mode = Node.PROCESS_MODE_INHERIT

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

	# ==================================================
	# Boss victory
	# ==================================================

	if battle_manager.current_battle_type == RoomData.RoomType.BOSS:

		print("BOSS DEFEATED")

		# --------------------------------------------------
		# World transition
		# --------------------------------------------------

		if run_manager.world_transition_pending:

			print(
				"World transition pending."
			)

			return

		# --------------------------------------------------
		# Final run completion
		# --------------------------------------------------

		print(
			"Final boss defeated."
		)

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

	var enemy_reward := PermanentProgressionManager.reward_enemy_defeats(
		run_manager.enemies_defeated
	)

	print(
		"Permanent progression reward:",
		enemy_reward
	)

	run_manager.reset_run()

	close_run_worlds()

	# Wait for BattleManager cleanup.
	await get_tree().process_frame

	print("================================")
	print("RETURNING TO HUB WORLD")
	print("================================")

	hub_world.open()


func close_run_worlds() -> void:

	print("================================")
	print("CLOSING RUN WORLDS")
	print("================================")

	map_manager.disable_scanner()
	map_ui.hide()

	if map_root != null:

		map_root.hide()
		map_root.process_mode = Node.PROCESS_MODE_DISABLED

	if battle_root != null:

		battle_root.hide()
		battle_root.process_mode = Node.PROCESS_MODE_DISABLED


func _on_battle_lost() -> void:

	print("================================")
	print("RUN FAILED")
	print("================================")

	returning_to_hub_after_battle = true

	map_manager.disable_scanner()

	PermanentProgressionManager.reward_enemy_defeats(
		run_manager.enemies_defeated
	)

	run_manager.reset_run()

	room_manager.close_active_room()

	map_ui.hide()

	if map_root != null:

		map_root.hide()
		map_root.process_mode = Node.PROCESS_MODE_DISABLED

	if battle_root != null:

		battle_root.hide()
		battle_root.process_mode = Node.PROCESS_MODE_DISABLED

	print("Waiting for battle cleanup...")


func _on_battle_cleanup_finished() -> void:

	print("================================")
	print("BATTLE CLEANUP FINISHED")
	print("================================")

	# ==================================================
	# World Transition
	# ==================================================

	if run_manager.world_transition_pending:

		print("================================")
		print("STARTING BETWEEN-WORLD LAB")
		print("Next World:", run_manager.current_world)
		print("================================")

		room_manager.close_active_room()

		open_between_world_lab()

		return

	# ==================================================
	# Failed Run
	# ==================================================

	if not returning_to_hub_after_battle:

		print(
			"Battle cleanup complete. "
			+ "Continuing current run."
		)

		return

	returning_to_hub_after_battle = false

	print("================================")
	print("Returning to HubWorld")
	print("================================")

	hub_world.open()


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
