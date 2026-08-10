extends Node
class_name TurnManager


# ==================================================
# Signals
# ==================================================


#signal battle_won(enemy)
#signal battle_lost


# ==================================================
# Enums
# ==================================================


enum TurnState {
	NONE,
	PLAYER_TURN,
	TARGET_SELECTION,
	ENEMY_TURN,
	END_TURN,
	BATTLE_OVER
}


# ==================================================
# Member Variables
# ==================================================


var current_state := TurnState.NONE

var player: PlayerAnimal
var enemies:Array[EnemyAnimal] = []

var selected_enemy: EnemyAnimal

var battle_sequence:BattleSequence

var battle_finished := false

# Target Selection
var pending_move: MoveResource
var pending_enemy_moves:Array = []

var waiting_for_target := false


# ==================================================
# Initialization
# ==================================================


func initialize(
	player_ref:PlayerAnimal,
	enemy_refs:Array[EnemyAnimal],
):

	player = player_ref
	enemies = enemy_refs

	print("")
	print("TURN MANAGER PLAYER ID:", player.get_instance_id())

	for enemy in enemies:
		print(
			enemy.name,
			" ID:",
			enemy.get_instance_id()
		)

	battle_sequence = BattleSequence.new()
	add_child(battle_sequence)
	# temp?
	print("================================")
	print("TURN MANAGER INITIALIZED")

	print("Player:")
	print(player)
	print("Player ID:", player.get_instance_id())

	for enemy in enemies:
		print("----------------")
		print(enemy.name)
		print(enemy)
		print("Enemy ID:", enemy.get_instance_id())

	print("================================")

	player.turn_manager = self

	for enemy in enemies:
		enemy.turn_manager = self

	battle_finished = false

	start_battle()

func _ready():

	if not GameEvents.move_selected.is_connected(
		_on_move_selected
	):

		GameEvents.move_selected.connect(
			_on_move_selected
		)

	if not GameEvents.target_selected.is_connected(
		_on_target_selected
	):

		GameEvents.target_selected.connect(
			_on_target_selected
		)

# ==================================================
# Battle Setup
# ==================================================

func start_battle():

	selected_enemy = null

	current_state = TurnState.NONE

	print("Turn system started")

	player.trigger_passive_event(
		"battle_start"
	)

	for enemy in enemies:

		enemy.trigger_passive_event(
			"battle_start"
		)

	##battle_ui.setup_moves(player)
	GameEvents.turn_changed.emit(
		current_state
	)

	GameEvents.moves_updated.emit(
		player
	)

	start_player_turn()


# ==================================================
# Player Turn
# ==================================================

func start_player_turn():

	if current_state == TurnState.BATTLE_OVER:
		return

	if player == null:
		print("Cannot start player turn. Player is missing.")
		return

	current_state = TurnState.PLAYER_TURN

	print("Player turn")

	player.reset_turn_state()

	player.trigger_passive_event(
		"turn_start"
	)

	# -----------------------------------
	# Status damage first
	# -----------------------------------

	player.process_status_effects()

	# -----------------------------------
	# Passive turn start effects
	# -----------------------------------

	player.tick_status_effects()

	# -----------------------------------
	# Update UI
	# -----------------------------------

	GameEvents.status_changed.emit(
		player,
		enemies
	)


	GameEvents.turn_changed.emit(
		current_state
	)


	GameEvents.moves_updated.emit(
		player
	)

	#player.process_status_effects()
#
	#for enemy in enemies:
#
		#if enemy.hp > 0:
			#enemy.process_status_effects()
#
	#GameEvents.status_changed.emit(
		#player,
		#get_active_enemy()
	#)
#
	## allow buttons
	#GameEvents.turn_changed.emit(
		#current_state
	#)
#
	#GameEvents.moves_updated.emit(
		#player
	#)


# ==================================================
# Move Selection
# ==================================================



func get_active_enemy() -> EnemyAnimal:

	if selected_enemy:

		if selected_enemy.hp > 0:

			return selected_enemy

	for enemy in enemies:

		if enemy.hp > 0:

			return enemy

	return null
	
	
func _on_move_selected(move_index: int):
	
	if current_state != TurnState.PLAYER_TURN:
		print("Not player turn")
		return

	#if waiting_for_target:
		#print("Already waiting for target selection")
		#return

	# ==================================================
	# Get Living Enemies
	# ==================================================

	var living_enemies: Array[EnemyAnimal] = []

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.hp > 0:
			living_enemies.append(enemy)

	if living_enemies.is_empty():
		print("No living enemies")
		return

	# ==================================================
	# Get Player Move
	# ==================================================

	var player_move: MoveResource = player.get_move(move_index)
	
	if player_move == null:
		print("Invalid player move")
		return
	
	print(
		"Player selected:",
		player_move.move_name
	)

	# ==================================================
	# ENEMY MOVE SELECTION
	# ==================================================

	var enemy_moves: Array = []

	for enemy in living_enemies:
		var move := enemy.choose_action(player)

		if move:

			enemy_moves.append(
				{
					"enemy": enemy,
					"move": move
				}
			)

			print(
				enemy.name,
				" selected:",
				move.move_name,
				"Priority:",
				move.priority,
				"Speed:",
				enemy.get_speed()
			)

	print(
		"Enemies selected:",
		enemy_moves.size()
	)

	# ==================================================
	# TARGET DEBUG
	# ==================================================

	print("========== TARGET DEBUG ==========")
	print("Move:", player_move.move_name)
	print("Target type:", player_move.target_type)
	print("SINGLE_ENEMY:", MoveResource.TargetType.SINGLE_ENEMY)
	print("SELF:", MoveResource.TargetType.SELF)
	print("ALL_ENEMIES:", MoveResource.TargetType.ALL_ENEMIES)
	print("Living enemies:", living_enemies.size())
	print("Current state:", current_state)
	print("==================================")

	# ==================================================
	# SELF TARGET
	# ==================================================

	if player_move.target_type == MoveResource.TargetType.SELF:

		resolve_turn(
			player_move,
			player,
			enemy_moves
		)

		return

	# ==================================================
	# ALL ENEMIES
	# ==================================================

	if player_move.target_type == MoveResource.TargetType.ALL_ENEMIES: 

		resolve_turn(
			player_move,
			living_enemies[0],
			enemy_moves
		)
		
		return

	# ==================================================
	# SINGLE ENEMY TARGET
	# ==================================================

	if player_move.target_type == MoveResource.TargetType.SINGLE_ENEMY:
	
		if living_enemies.size() == 1:

			resolve_turn(
				player_move,
				living_enemies[0],
				enemy_moves
			)

			return

		print("==================================")
		print("Waiting for target selection")
		print("Enemies available:", living_enemies.size())
		print("==================================")

		pending_move = player_move
		pending_enemy_moves = enemy_moves
		waiting_for_target = true

		current_state = TurnState.TARGET_SELECTION

		GameEvents.turn_changed.emit(
			current_state
		)

		GameEvents.request_target_selection.emit(
			living_enemies
		)

		return

	print(
		"WARNING: Unsupported target type:",
		player_move.target_type
	)


	## ==================================================
	## Multiple Enemies - Request Target
	## ==================================================
#
		#print(
			#"Waiting for target selection"
		#)
#
		#pending_move = player_move
		#pending_enemy_moves = enemy_moves.duplicate(true)
#
		#waiting_for_target = true
		#current_state = TurnState.TARGET_SELECTION
#
		#GameEvents.turn_changed.emit(
			#current_state
		#)
	#
		#GameEvents.request_target_selection.emit(
			#living_enemies
		#)
#
	#print(
		#"Target selection requested for",
		#living_enemies.size(),
		#"enemies"
	#)


func _on_target_selected(enemy: EnemyAnimal):

	if not waiting_for_target:
		return

	if enemy == null:
		return

	if not is_instance_valid(enemy):
		return

	if enemy.hp <= 0:

		print(
			"Cannot target defeated enemy"
		)

		return

	print(
		"Target selected:",
		enemy.name
	)
	
	waiting_for_target = false

	selected_enemy = enemy

	# ==========================================
	# Preserve the queued enemy actions
	# ==========================================

	var selected_move := pending_move
	var selected_enemy_moves := pending_enemy_moves.duplicate()

	# ==========================================
	# Clear target-selection state
	# ==========================================

	pending_move = null
	pending_enemy_moves.clear()

	# ==========================================
	# Clear target-selection state
	# ==========================================

	await resolve_turn(
		selected_move,
		enemy,
		selected_enemy_moves
	)


# ==================================================
# Turn Resolution
# ==================================================


func resolve_turn(
	player_move: MoveResource,
	target_enemy: AnimalBase,
	enemy_moves:Array
):

	if battle_finished:
		return

	if player_move == null:
		return

	# ==================================================
	# BUILD ACTION LIST
	# ==================================================

	var actions: Array = []

	# ================================
	# PLAYER ACTION
	# ================================

	actions.append(
		{
			"actor": player,
			"move": player_move,
			"target": target_enemy
		}
	)

	# ==================================================
	# Enemy Actions
	# ==================================================

	for data in enemy_moves:

		var enemy: EnemyAnimal = data["enemy"]
		var enemy_move: MoveResource = data["move"]

		if not is_instance_valid(enemy):
			continue

		if enemy.hp <= 0:
			continue

		if enemy_move == null:
			continue

		actions.append(
			{
				"actor": enemy,
				"move": enemy_move,
				"target": player
			}
		)
	
	# ==================================================
	# SORT ACTIONS
	# ==================================================

	actions.sort_custom(
		_compare_actions
	)

	print("")
	print("========== ACTION ORDER ==========")

	for action in actions:

		var actor: AnimalBase = action["actor"]
		var move: MoveResource = action["move"]

		print(
			actor.name,
			" -> ",
			move.move_name,
			" | Priority:",
			move.priority,
			" | Speed:",
			actor.get_speed()
		)

	print("==================================")

	# ==================================================
	# EXECUTE ACTIONS
	# ==================================================

	current_state = TurnState.ENEMY_TURN

	GameEvents.turn_changed.emit(
		current_state
	)

	for action in actions:

		if battle_finished:
			return

		var actor: AnimalBase = action["actor"]
		var move: MoveResource = action["move"]
		var action_target: AnimalBase = action["target"]

		# ------------------------------------------------
		# Skip defeated actors
		# ------------------------------------------------

		if not is_instance_valid(actor):
			continue

		if actor.hp <= 0:
			continue

		# ------------------------------------------------
		# Skip invalid targets
		# ------------------------------------------------

		if action_target != null:

			if not is_instance_valid(action_target):
				continue

			if action_target.hp <= 0:
				continue

		# ------------------------------------------------
		# Execute
		# ------------------------------------------------

		await _execute_action(
			actor,
			move,
			action_target
		)

		if check_battle_end():
			return

	# ==================================================
	# END OF ROUND
	# ==================================================

	if check_battle_end():
		return

	end_turn()


func _compare_actions(
	a: Dictionary,
	b: Dictionary
) -> bool:

	var move_a: MoveResource = a["move"]
	var move_b: MoveResource = b["move"]

	var actor_a: AnimalBase = a["actor"]
	var actor_b: AnimalBase = b["actor"]

	# ==================================================
	# Priority
	# ==================================================

	if move_a.priority != move_b.priority:

		return move_a.priority > move_b.priority

	# ==================================================
	# Speed
	# ==================================================

	var speed_a := actor_a.get_speed()
	var speed_b := actor_b.get_speed()

	if speed_a != speed_b:

		return speed_a > speed_b

	# ==================================================
	# Tie
	# ==================================================
	#
	# Return false so the existing order is preserved.
	#
	# ==================================================

	return false


func _execute_action(
	actor: AnimalBase,
	move: MoveResource,
	target: AnimalBase
):

	if not is_instance_valid(actor):
		return

	if actor.hp <= 0:
		return

	print("")
	print(
		"EXECUTING ACTION:",
		actor.name,
		"->",
		move.move_name
	)

	print(
		"Priority:",
		move.priority,
		"Speed:",
		actor.get_speed()
	)

	if target:

		print(
			"Target:",
			target.name,
			"HP:",
			target.hp
		)

	await move.execute(
		actor,
		target
	)


# ==================================================
# Turn End
# ==================================================


func end_turn():

	if battle_finished:
		return

	if current_state == TurnState.BATTLE_OVER:
		return

	if player == null:
		return

	current_state = TurnState.END_TURN

	GameEvents.turn_changed.emit(
		current_state
	)

	trigger_turn_end_effects()

	if check_battle_end():
		return

	start_player_turn()


func trigger_turn_end_effects():

	if player:
		player.trigger_passive_event(
			"turn_end"
		)

	for enemy in enemies:

		if enemy.hp > 0:

			enemy.trigger_passive_event(
				"turn_end"
			)


# ==================================================
# Battle Checks
# ==================================================


func check_battle_end() -> bool:

	if battle_finished:
		return true

	if player == null:
		print("Battle check failed: player is null")
		return true

	# ==================================================
	# Player Defeated
	# ==================================================

	if player.hp <= 0:
		print("Player defeated")

		battle_finished = true
		current_state = TurnState.BATTLE_OVER

		# ------------------------------------------
		# Battle End Passive Effects
		# ------------------------------------------

		player.trigger_passive_event(
			"battle_end"
		)

		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.trigger_passive_event(
					"battle_end"
				)

		# ------------------------------------------
		# Notify Game
		# ------------------------------------------

		print("Emitting battle_lost")

		GameEvents.battle_lost.emit()

		return true

	# ==================================================
	# Enemy Defeat Check
	# ==================================================

	var living_enemies := 0

	print("----- Checking Enemies -----")

	for enemy in enemies:
		if enemy == null:
			continue

		print(enemy.name, " HP:", enemy.hp)

		if enemy.hp > 0:
			living_enemies += 1

	print("Living enemies:", living_enemies)

	if living_enemies > 0:
		return false

	# ==================================================
	# All Enemies Defeated
	# ==================================================

	print("All enemies defeated")

	battle_finished = true
	current_state = TurnState.BATTLE_OVER

	player.trigger_passive_event("battle_end")

	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.trigger_passive_event("battle_end")

	print("Emitting battle_won")

	GameEvents.battle_won.emit(
		enemies[0] if enemies.size() > 0 else null
	)

	return true


# ==================================================
# Cleanup
# ==================================================

func reset():

	print("===== TURN MANAGER RESET =====")

	print("Old player:", player)

	for enemy in enemies:
		print(
			"Old enemy:",
			enemy
		)

	current_state = TurnState.NONE

	if is_instance_valid(battle_sequence):
		battle_sequence.queue_free()

	battle_sequence = null

	player = null

	enemies.clear()

	selected_enemy = null

	pending_move = null

	pending_enemy_moves.clear()

	waiting_for_target = false

	battle_finished = false

	print("TurnManager references cleared")
