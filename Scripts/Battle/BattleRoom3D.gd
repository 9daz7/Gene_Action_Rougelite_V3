extends Room3DBase


@onready var action_battle_ui: ActionBattleUI = $ActionBattleUI
var combat_controller: ActionCombatController3D = null

var remaining_enemies: int = 0

var reward_enemy_data: EnemyResource = null
var reward_requested_once: bool = false


func _ready() -> void:

	super._ready()

	if not is_instance_valid(player):
		push_error("BattleRoom3D: Player reference is missing.")
		return

	var party_root := player.get_parent()

	if party_root == null:
		push_error("BattleRoom3D: Player has no party root.")
		return

	combat_controller = party_root.get_node_or_null(
		"ActionCombatController3D"
	) as ActionCombatController3D

	if combat_controller == null:
		push_error(
			"BattleRoom3D: ActionCombatController3D "
			+ "was not found in Player3D."
		)
		return

	action_battle_ui.setup(
		player,
		deebo,
		combat_controller
	)

	print(
		"TEST ROOM HEALTH AFTER UI SETUP | ",
		"Player: ", player.current_health,
		"/", player.max_health,
		" | Deebo: ", deebo.current_health,
		"/", deebo.max_health
	)

	action_battle_ui.update_move_names()

	_register_enemies()


#func _on_required_character_died() -> void:
#
	#if run_failed:
		#return
#
	#run_failed = true
	#print("RUN FAILED: Player or Deebo died.")
#
	#_stop_combat()


func _register_enemies() -> void:

	#var enemies := get_tree().get_nodes_in_group("enemies_3d")
	var connected_enemies: Array[Node] = []
	var combined_gene_pool: Array[GeneResource] = []

	for controller in find_children("*", "", true, false):
		if not controller.is_in_group("enemies_3d"):
			continue

		var enemy := controller.get_parent() as CharacterBody3D

		if enemy == null or connected_enemies.has(enemy):
			continue

		connected_enemies.append(enemy)

		# Get this enemy's resource.
		var enemy_data := enemy.get("enemy_data") as EnemyResource

		if enemy_data != null:

			# Use the first valid enemy as the encounter reward source.
			if reward_enemy_data == null:
				reward_enemy_data = enemy_data

			# Combine gene pools from all enemies.
			for gene in enemy_data.drop_gene_pool:
				if not combined_gene_pool.has(gene):
					combined_gene_pool.append(gene)

		if enemy.has_signal("died"):
			if not enemy.died.is_connected(_on_enemy_died):
				enemy.died.connect(_on_enemy_died)

	remaining_enemies = connected_enemies.size()

	# Give the encounter reward access to every enemy's gene pool.
	if reward_enemy_data != null:
		reward_enemy_data = reward_enemy_data.duplicate()
		reward_enemy_data.drop_gene_pool = combined_gene_pool

	print("Enemies registered: ", remaining_enemies)
	print("Encounter gene pool: ", combined_gene_pool.size())

	if remaining_enemies == 0:
		push_error("BattleRoom3D: No enemies registered.")


func _on_enemy_died() -> void:

	if room_completed or run_failed or reward_requested_once:
		return

	remaining_enemies = maxi(remaining_enemies - 1, 0)

	print("Enemies remaining: ", remaining_enemies)

	if remaining_enemies == 0:
		_on_battle_defeated()


func _on_battle_defeated() -> void:

	if room_completed or run_failed or reward_requested_once:
		return

	if reward_enemy_data == null:
		push_error(
			"BattleRoom3D: Cannot generate reward. "
			+ "EnemyResource is missing."
		)
		return

	reward_requested_once = true

	print("================================")
	print("BATTLE ENCOUNTER DEFEATED")
	print("REQUESTING BATTLE REWARD")
	print("Enemy: ", reward_enemy_data.enemy_name)
	print("================================")

	reward_requested.emit(reward_enemy_data)


#func _register_room_exits() -> void:
#
	#room_exits.clear()
#
	#for node in find_children("*", "RoomExit3D", true, false):
		#if not node is RoomExit3D:
			#continue
#
		#var exit := node as RoomExit3D
		#room_exits.append(exit)
		#exit.set_enabled(false)
#
		#if not exit.exit_entered.is_connected(_on_room_exit_entered):
			#exit.exit_entered.connect(_on_room_exit_entered)
#
		#print("Registered 3D exit: ", exit.name, " | ID: ", exit.exit_id)
#
	#print("Total 3D exits registered: ", room_exits.size())
#
#
#func _on_room_exit_entered(exit_id: int) -> void:
#
	#if run_failed or not room_completed:
		#return
#
	#print("Room exit selected: ", exit_id)
	#room_exit_selected.emit(exit_id)


#func _stop_combat() -> void:
#
	## Stop the player.
	#if is_instance_valid(player):
		#player.set_physics_process(false)
		#player.velocity = Vector3.ZERO
#
	## Stop Deebo.
	#if is_instance_valid(deebo):
		#deebo.set_physics_process(false)
		#deebo.velocity = Vector3.ZERO
#
	## Stop enemy controllers.
	#for enemy_controller in get_tree().get_nodes_in_group("enemy_controllers_3d"):
		#if is_instance_valid(enemy_controller):
			#enemy_controller.set_physics_process(false)
#
	#print("Combat stopped.")
