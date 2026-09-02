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

# potion duration
var active_potion_effects: Array[Dictionary] = []

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

	print("================================")
	print("TURN MANAGER READY")
	print("TurnManager ID:", get_instance_id())
	print("Connecting to GameEvents")
	print("================================")

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

	print(
		"Target selected connected:",
		GameEvents.target_selected.is_connected(
			_on_target_selected
		)
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

	if not player.is_alive():
		check_battle_end()
		return

	current_state = TurnState.PLAYER_TURN

	print("Player turn")

	_tick_potion_effects()

	process_turn_start_effects(
		player
	)

	if check_battle_end():
		return

	if player.consume_stun():

		end_turn()

		return

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


func process_turn_start_effects(
	animal: AnimalBase
):

	if animal == null:
		return

	if not is_instance_valid(animal):
		return

	if not animal.is_alive():
		return

	animal.reset_turn_state()

	animal.trigger_passive_event(
		"turn_start"
	)

	animal.process_status_effects()

	if animal.is_alive():

		animal.tick_status_effects()

	GameEvents.status_changed.emit(
		animal,
		enemies
	)


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

	print("")
	print("================================")
	print("TURN MANAGER RECEIVED TARGET")
	print("TurnManager ID:", get_instance_id())
	print("Enemy:", enemy)
	print("Enemy name:", enemy.name if enemy else "NULL")
	print("Waiting for target:", waiting_for_target)
	print("Current state:", current_state)
	print("Pending move:", pending_move)
	print("Pending enemy moves:", pending_enemy_moves.size())
	print("================================")

	if not waiting_for_target:
		print("IGNORING TARGET: not waiting for target")
		return

	if enemy == null:
		print("IGNORING TARGET: enemy is null")
		return

	if not is_instance_valid(enemy):
		print("IGNORING TARGET: enemy is invalid")
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

	print("================================")
	print("RESOLVING SELECTED TARGET")
	print("Move:", selected_move.move_name if selected_move else "NULL")
	print("Target:", enemy.name)
	print("Enemy actions:", selected_enemy_moves.size())
	print("================================")

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
		# Skip invalid actors
		# ------------------------------------------------

		if not is_instance_valid(actor):
			continue

		if actor.hp <= 0:
			continue

		# ------------------------------------------------
		# Turn-start effects
		# ------------------------------------------------

		if actor is EnemyAnimal:

			process_turn_start_effects(
				actor
			)

			if check_battle_end():
				return

			if actor.hp <= 0:
				continue

			if actor.consume_stun():
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
		# Execute action
		# ------------------------------------------------

		await _execute_action(
			actor,
			move,
			action_target
		)

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
# Item Use
# ==================================================


func use_player_potion(
	slot_index: int
) -> bool:

	# ==================================================
	# Validate turn
	# ==================================================

	if current_state != TurnState.PLAYER_TURN:

		print(
			"Cannot use potion. Not player turn."
		)

		return false

	if battle_finished:

		return false

	# ==================================================
	# Validate player.
	# ==================================================

	if player == null:

		print(
			"Cannot use potion. Player is missing."
		)

		return false

	# ==================================================
	# Get RunManager
	# ==================================================

	var run_manager: RunManager = player.run_manager

	if run_manager == null:

		print(
			"Cannot use potion. RunManager is missing."
		)

		return false

	# ==================================================
	# Get potion from player's bag.
	# ==================================================

	var potions := run_manager.get_run_potions()

	if slot_index < 0:
		return false

	if slot_index >= potions.size():
		return false

	var potion: PotionResource = potions[slot_index]

	if potion == null:

		print(
			"No potion in slot:",
			slot_index
		)

		return false

	print("================================")
	print("USING POTION")
	print("Potion:", potion.potion_name)
	print("Slot:", slot_index)
	print("================================")

	# ==================================================
	# Apply healing.
	# ==================================================

	if potion.heal_amount > 0:

		player.heal(
			potion.heal_amount
		)

		print(
			"Potion healed:",
			potion.heal_amount
		)

	# ==================================================
	# Apply temporary stat modifiers.
	# ==================================================

	if potion.attack_bonus != 0:

		player.modify_attack(
			potion.attack_bonus
		)

		_track_potion_stat(
			"attack",
			potion.attack_bonus,
			potion.duration
		)

		print(
			"Attack bonus:",
			potion.attack_bonus,
			"Duration:",
			potion.duration
		)

	if potion.defense_bonus != 0:

		player.modify_defense(
			potion.defense_bonus
		)

		_track_potion_stat(
			"defense",
			potion.defense_bonus,
			potion.duration
		)

		print(
			"Defense bonus:",
			potion.defense_bonus,
			"Duration:",
			potion.duration
		)


	if potion.speed_bonus != 0:

		player.modify_speed(
			potion.speed_bonus
		)

		_track_potion_stat(
			"speed",
			potion.speed_bonus,
			potion.duration
		)

		print(
			"Speed bonus:",
			potion.speed_bonus,
			"Duration:",
			potion.duration
		)

	# ==================================================
	# Consume Potion
	# ==================================================

	var consumed := run_manager.remove_potion_from_run(
		slot_index
	)

	if consumed == null:

		print(
			"ERROR: Potion effect applied "
			+ "but potion could not be removed."
		)

		return false

	print(
		"Potion consumed:",
		consumed.potion_name
	)

	# ==================================================
	# Update UI.
	# ==================================================

	GameEvents.status_changed.emit(
		player,
		enemies
	)

	# ==================================================
	# Enemy Turn
	# ==================================================

	await _resolve_enemy_turn_after_item()

	return true


# ==================================================
# Potion Effects
# ==================================================


func _track_potion_stat(
	stat_name: String,
	amount: int,
	duration: int
) -> void:

	if amount == 0:
		return

	if duration <= 0:
		return

	active_potion_effects.append(
		{
			"stat": stat_name,
			"amount": amount,
			"turns": duration
		}
	)

	print(
		"Tracked potion effect:",
		stat_name,
		amount,
		"for",
		duration,
		"turns"
	)

func _tick_potion_effects() -> void:

	if player == null:
		return

	if active_potion_effects.is_empty():
		return

	for effect in active_potion_effects:

		effect["turns"] -= 1

	var expired: Array[Dictionary] = []

	for effect in active_potion_effects:

		print(
			"POTION EFFECT:",
			effect["stat"],
			"Amount:",
			effect["amount"],
			"Turns remaining:",
			effect["turns"]
		)

		if effect["turns"] <= 0:

			expired.append(effect)

	for effect in expired:

		match effect["stat"]:

			"attack":

				player.modify_attack(
					-effect["amount"]
				)

			"defense":

				player.modify_defense(
					-effect["amount"]
				)

			"speed":

				player.modify_speed(
					-effect["amount"]
				)

		active_potion_effects.erase(effect)

		print(
			"Potion effect expired:",
			effect["stat"],
			effect["amount"]
		)


func _resolve_enemy_turn_after_item() -> void:

	if battle_finished:
		return

	if player == null:
		return

	# ==================================================
	# Get Living Enemies
	# ==================================================

	var living_enemies: Array[EnemyAnimal] = []

	for enemy in enemies:

		if not is_instance_valid(enemy):
			continue

		if enemy.hp <= 0:
			continue

		living_enemies.append(enemy)

	if living_enemies.is_empty():

		check_battle_end()

		return

	# ==================================================
	# Enemy Actions
	# ==================================================

	var enemy_actions: Array = []


	for enemy in living_enemies:

		var move := enemy.choose_action(player)

		if move == null:
			continue

		enemy_actions.append(
			{
				"enemy": enemy,
				"move": move
			}
		)

		print(
			enemy.name,
			" selected after potion:",
			move.move_name,
			"Priority:",
			move.priority,
			"Speed:",
			enemy.get_speed()
		)

	# ==================================================
	# Enemy Turn
	# ==================================================

	current_state = TurnState.ENEMY_TURN

	GameEvents.turn_changed.emit(
		current_state
	)

	for data in enemy_actions:

		if battle_finished:
			return

		var enemy: EnemyAnimal = data["enemy"]
		var move: MoveResource = data["move"]

		if not is_instance_valid(enemy):
			continue

		if enemy.hp <= 0:
			continue

		# ----------------------------------------------
		# Enemy turn-start effects
		# ----------------------------------------------

		process_turn_start_effects(
			enemy
		)

		if check_battle_end():
			return

		if enemy.hp <= 0:
			continue

		if enemy.consume_stun():
			continue

		# ----------------------------------------------
		# Execute
		# ----------------------------------------------

		await _execute_action(
			enemy,
			move,
			player
		)

	# ==================================================
	# Battle Check
	# ==================================================

	if check_battle_end():
		return


	# ==================================================
	# End Round
	# ==================================================

	end_turn()


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

	active_potion_effects.clear()

	print("TurnManager references cleared")
