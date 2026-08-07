extends Node
class_name TurnManager


# ==================================================
# Signals
# ==================================================


signal battle_won(enemy)
signal battle_lost


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

	print("================================")
	print("TURN MANAGER INITIALIZED")
	print("Enemy count:", enemies.size())

	for enemy in enemies:
		print("Enemy:", enemy.name)

	print("================================")

	player.turn_manager = self

	for enemy in enemies:
		enemy.turn_manager = self

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

	GameEvents.battle_started.emit()

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

	player.tick_status_effects()

	player.reset_turn_state()

	# -----------------------------------
	# Status damage first
	# -----------------------------------

	player.process_status_effects()

	# -----------------------------------
	# Passive turn start effects
	# -----------------------------------

	player.trigger_passive_event(
		"turn_start"
	)

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

	var living_enemies:Array[EnemyAnimal] = []

	for enemy in enemies:

		if enemy.hp > 0:

			living_enemies.append(enemy)


	if living_enemies.is_empty():

		print("No living enemies")
		return
		
	var player_move = player.get_move(move_index)
	
	if player_move == null:
		print("Invalid player move")
		return
	
	print(
		"Player selected:",
		player_move.move_name
	)
	
	var enemy_moves:Array = []

	for enemy in enemies:
		if enemy.hp > 0:
			var move = enemy.choose_action(player)

			if move:
				enemy_moves.append(
					{
						"enemy":enemy,
						"move":move
					}
				)
				
	print(
		"Enemies attacking:",
		enemy_moves.size()
	)

	if player_move.target_type == MoveResource.TargetType.SELF:

		resolve_turn(
			player_move,
			get_active_enemy(),
			enemy_moves
		)


	elif living_enemies.size() == 1:

		resolve_turn(
			player_move,
			living_enemies[0],
			enemy_moves
		)

	else:

		print(
			"Waiting for target selection"
		)

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


func _on_target_selected(enemy:EnemyAnimal):

	if not waiting_for_target:
		return

	if enemy == null:
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

	resolve_turn(
		pending_move,
		enemy,
		pending_enemy_moves
	)

	pending_move = null
	pending_enemy_moves.clear()

# ==================================================
# Turn Resolution
# ==================================================


func resolve_turn(
	player_move: MoveResource,
	target_enemy: EnemyAnimal,
	enemy_moves:Array
):

# -----------------------------
# Player action
# -----------------------------

	print(
		"Player uses:",
		player_move.move_name
	)

	GameEvents.move_used.emit(
		player,
		player_move
	)

	player_move.execute(
		player,
		target_enemy
	)

	check_battle_end()

	if current_state == TurnState.BATTLE_OVER:
		return

# -----------------------------
# Enemy turn begins
# -----------------------------

	current_state = TurnState.ENEMY_TURN
	
	GameEvents.turn_changed.emit(
		current_state
	)

	for enemy in enemies:

		if enemy.hp <= 0:
			continue

		enemy.trigger_passive_event(
			"turn_start"
		)

		enemy.process_status_effects()

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

		enemy.tick_status_effects()


# -----------------------------
# Enemy actions
# -----------------------------
	for data in enemy_moves:

		var enemy = data.enemy
		var move = data.move

		# Skip dead enemies
		if enemy.hp <= 0:
			continue

		print(
			enemy.name,
			" uses ",
			move.move_name
		)

		GameEvents.move_used.emit(
			enemy,
			move
		)

		move.execute(
			enemy,
			player
		)

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

	end_turn()


# ==================================================
# Turn End
# ==================================================

func end_turn():
	
	if current_state == TurnState.BATTLE_OVER:
		return

	if player == null:
		return

	current_state = TurnState.END_TURN

	GameEvents.turn_changed.emit(current_state)


	trigger_turn_end_effects()

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


func check_battle_end():

	if player == null:
		return

	if player.hp <= 0:
		print("Player defeated")

		current_state = TurnState.BATTLE_OVER

		player.trigger_passive_event(
			"battle_end"
		)

		for defeated_enemy in enemies:

			defeated_enemy.trigger_passive_event(
				"battle_end"
			)

		battle_lost.emit()

		return

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
		return

	print("All enemies defeated")

	current_state = TurnState.BATTLE_OVER

	player.trigger_passive_event("battle_end")

	for enemy in enemies:
		if enemy:
			enemy.trigger_passive_event("battle_end")

	battle_won.emit(
		enemies[0] if enemies.size() > 0 else null
	)

		#if battle_ui:
			#battle_ui.hide()


# ==================================================
# Cleanup
# ==================================================

func reset():

	current_state = TurnState.NONE

	player = null

	enemies.clear()


	selected_enemy = null

	pending_move = null

	pending_enemy_moves.clear()

	waiting_for_target = false


	print("TurnManager reset")
