extends CanvasLayer
class_name BattleUI


# ==================================================
# Signals
# ==================================================

# ==================================================
#preloads
# ==================================================

const ENEMY_STATUS_UI = preload(
	"res://Scenes/UI/EnemyStatusUI.tscn"
)


# ==================================================
# Onready Variables
# ==================================================

@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

@onready var item_button: Button = $ItemButton

@onready var player_name_label = $PlayerPanel/PlayerNameLabel
#@onready var enemy_name_label = $EnemyPanel/EnemyNameLabel
@onready var enemy_container = $EnemyPanel/EnemyStatusContainer
@onready var target_selection_ui = get_node_or_null("TargetSelectionUI")

@onready var player_hp_bar = $PlayerPanel/PlayerHP
#@onready var enemy_hp_bars = [
	#$EnemyPanel/EnemyHPContainer/EnemyHP1,
	#$EnemyPanel/EnemyHPContainer/EnemyHP2,
	#$EnemyPanel/EnemyHPContainer/EnemyHP3
#]

@onready var player_status_label = $PlayerPanel/PlayerStatusLabel
@onready var potion_effects_container: VBoxContainer = (
	$PlayerPanel/PotionEffectsContainer
)

@onready var enemy_status_label = $EnemyPanel/EnemyStatusLabel

@onready var item_bag_panel: Control = $ItemBagPanel

@onready var potion_button_1: Button = (
	$ItemBagPanel/VBoxContainer/PotionButton1
)

@onready var potion_button_2: Button = (
	$ItemBagPanel/VBoxContainer/PotionButton2
)

@onready var potion_button_3: Button = (
	$ItemBagPanel/VBoxContainer/PotionButton3
)

@onready var item_bag_close_button: Button = (
	$ItemBagPanel/VBoxContainer/CloseButton
)


# ==================================================
# Member Variables
# ==================================================


var move_buttons:Array[Button] = []

var enemy_ui := {}

var selecting_target := false

var current_player: PlayerAnimal = null


# ==================================================
# Initialization
# ==================================================


func _ready():

	print("BattleUI ready")

	_setup_buttons()

	item_bag_panel.hide()

	item_bag_close_button.pressed.connect(
		_close_item_bag
	)

	if not GameEvents.animal_hp_changed.is_connected(update_hp):

		GameEvents.animal_hp_changed.connect(
			update_hp
		)

	if not GameEvents.moves_updated.is_connected(setup_moves):

		GameEvents.moves_updated.connect(
			setup_moves
		)
#
	if not GameEvents.battle_names_updated.is_connected(
		setup_names
	):

		GameEvents.battle_names_updated.connect(
			setup_names
		)

	if not GameEvents.status_changed.is_connected(
		update_status_labels
	):

		GameEvents.status_changed.connect(
			update_status_labels
		)

	if not GameEvents.battle_initialized.is_connected(
		setup_battle_ui
	):
		GameEvents.battle_initialized.connect(
			setup_battle_ui
		)

	if not GameEvents.request_target_selection.is_connected(
		show_target_selection
	):

		GameEvents.request_target_selection.connect(
			show_target_selection
		)

	if not GameEvents.target_selected.is_connected(
		_on_target_selected
	):

		GameEvents.target_selected.connect(
			_on_target_selected
		)

	if not GameEvents.turn_changed.is_connected(
		_on_turn_changed
	):

		GameEvents.turn_changed.connect(
			_on_turn_changed
		)

	if not GameEvents.potion_effects_changed.is_connected(
		update_potion_effects
	):

		GameEvents.potion_effects_changed.connect(
			update_potion_effects
		)


func setup_enemy_ui(
	enemies:Array[EnemyAnimal]
):

	for child in enemy_container.get_children():
		child.queue_free()

	enemy_ui.clear()

	for enemy in enemies:

		var ui = ENEMY_STATUS_UI.instantiate()

		enemy_container.add_child(ui)

		ui.setup(enemy)


		enemy_ui[enemy] = ui


# ==================================================
# Public Functions
# ==================================================


func _refresh_item_bag() -> void:

	if current_player == null:
		return

	var run_manager := current_player.run_manager

	if run_manager == null:
		return

	var potions := run_manager.get_run_potions()

	var buttons := [
		potion_button_1,
		potion_button_2,
		potion_button_3
	]

	for i in range(buttons.size()):

		var button: Button = buttons[i]

		button.text = "Empty"
		button.disabled = true

		if i >= potions.size():
			continue

		var potion: PotionResource = potions[i]

		if potion == null:
			continue

		button.text = potion.potion_name
		button.disabled = false


func _close_item_bag() -> void:

	item_bag_panel.hide()

	if current_player == null:
		return

	if current_player.turn_manager == null:
		return

	if current_player.turn_manager.current_state == (
		TurnManager.TurnState.PLAYER_TURN
	):

		enable_moves()


func setup_names(
		player: PlayerAnimal,
		enemies:Array
	):

	if player:
		player_name_label.text = (
			player.get_display_name()
		)


func setup_moves(player):

	if player == null:
		return

	print("Updating battle moves")

	var moves = player.get_battle_moves()

	for move in moves:
		print("MOVE:", move.move_name)

	for i in range(move_buttons.size()):

		if i < moves.size():

			move_buttons[i].text = moves[i].move_name
			move_buttons[i].disabled = false

		else:

			move_buttons[i].text = "Empty"
			move_buttons[i].disabled = true


func enable_moves():

	for button in move_buttons:
		button.disabled = false


func disable_moves():

	for button in move_buttons:
		button.disabled = true


func update_status_labels(
	player:AnimalBase,
	enemies:Array
):

	player_status_label.text = (
		get_status_text(player)
	)

	for enemy in enemies:

		if enemy_ui.has(enemy):

			enemy_ui[enemy].update_status()


func update_potion_effects(
	_player = null
) -> void:

	if potion_effects_container == null:
		return

	for child in potion_effects_container.get_children():
		child.queue_free()

	if current_player == null:
		return

	if current_player.turn_manager == null:
		return

	var effects := (
		current_player.turn_manager.get_active_potion_effects()
	)

	for effect in effects:

		var label := Label.new()

		var stat: String = effect["stat"]
		var amount: int = effect["amount"]
		var turns: int = effect["turns"]

		var sign := "+"

		if amount < 0:
			sign = ""

		label.text = (
			stat.capitalize()
			+ " "
			+ sign
			+ str(amount)
			+ "  "
			+ str(turns)
			+ " turn"
		)

		if turns != 1:
			label.text += "s"

		potion_effects_container.add_child(label)


func get_status_text(animal:AnimalBase) -> String:

	if animal == null:
		return ""

	var text = ""

	for status in animal.status_effects:

		text += (
			status.effect_name
			+ " x"
			+ str(status.stacks)
			+ "\n"
		)

	return text


func setup_battle_ui(
	player,
	enemies
):

	current_player = player

	setup_enemy_ui(
		enemies
	)

	setup_names(
		player,
		enemies
	)

	update_status_labels(
		player,
		enemies
	)

	if player:

		update_hp(
			player,
			player.hp,
			player.get_max_hp()
		)

	print(
		"Battle UI initialized"
	)

	update_potion_effects()


func show_target_selection(
	enemies:Array
):

	if target_selection_ui == null:
		push_error("TargetSelectionUI missing from BattleUI")
		return

	selecting_target = true

	disable_moves()

	target_selection_ui.show_targets(
		enemies
	)


func cancel_target_selection() -> void:

	if not selecting_target:
		return

	print("Cancelling target selection")

	selecting_target = false

	if target_selection_ui:
		target_selection_ui.hide()

	enable_moves()


func _on_target_selected(
	enemy: EnemyAnimal
):

	if not is_inside_tree():
		return

	if not selecting_target:
		return

	if not is_instance_valid(enemy):
		return

	print(
		"BattleUI target selected:",
		enemy.name
	)

	selecting_target = false

	if target_selection_ui:
		target_selection_ui.hide()

	enable_moves()


func _on_turn_changed(
	new_state: TurnManager.TurnState
) -> void:

	if new_state != TurnManager.TurnState.PLAYER_TURN:

		item_bag_panel.hide()

	else:

		update_potion_effects()


func update_hp(
	animal: AnimalBase,
	current_hp:int,
	max_hp:int
):

	print("")
	print("===== BATTLE UI HP UPDATE =====")
	print("Animal:", animal)
	print("Name:", animal.name)
	print("Instance:", animal.get_instance_id())
	print("HP:", current_hp, "/", max_hp)
	print("Is Enemy:", animal is EnemyAnimal)
	print("Enemy UI has animal:", enemy_ui.has(animal))
	print("Enemy UI dictionary size:", enemy_ui.size())


	if animal is PlayerAnimal:

		print(
			"PLAYER HP UPDATE:",
			current_hp,
			"/",
			max_hp
		)

		player_hp_bar.max_value = max_hp
		player_hp_bar.value = current_hp

	elif animal is EnemyAnimal:

		print(
			"ENEMY HP UPDATE:",
			animal.name,
			current_hp,
			"/",
			max_hp
		)

		if enemy_ui.has(animal):

			enemy_ui[animal].update_hp(
				current_hp,
				max_hp
			)
			
			print("SUCCESS: Enemy HP bar updated")

		else:

			print(
				"ERROR: No EnemyStatusUI found for",
				animal.name,
				"ID:",
				animal.get_instance_id()
			)


# ==================================================
# Private Functions
# ==================================================

func _setup_buttons():

	move_buttons = [
		attack_button,
		protect_button,
		move3_button,
		move4_button
	]

	item_button.pressed.connect(
		_open_item_bag
	)

	potion_button_1.pressed.connect(
		func():
			_use_potion(0)
	)

	potion_button_2.pressed.connect(
		func():
			_use_potion(1)
	)

	potion_button_3.pressed.connect(
		func():
			_use_potion(2)
	)

	attack_button.pressed.connect(
		func():

			print("ATTACK BUTTON CLICKED")

			GameEvents.move_selected.emit(0)
	)


	protect_button.pressed.connect(
		func():

			print("PROTECT BUTTON CLICKED")

			GameEvents.move_selected.emit(1)
	)


	move3_button.pressed.connect(
		func():
			GameEvents.move_selected.emit(2)
	)


	move4_button.pressed.connect(
		func():
			GameEvents.move_selected.emit(3)
	)


	_clear_optional_moves()


func _open_item_bag() -> void:

	print("ITEM BUTTON CLICKED")

	if current_player == null:

		print("No current player.")

		return

	if current_player.turn_manager == null:

		print("Player has no TurnManager.")

		return

	if current_player.turn_manager.current_state != (
		TurnManager.TurnState.PLAYER_TURN
	):

		print(
			"Cannot open items. Current state:",
			current_player.turn_manager.current_state
		)

		return

	print("Opening Player's Bag")

	disable_moves()

	item_bag_panel.show()

	_refresh_item_bag()


func _use_potion(slot_index: int) -> void:

	print("================================")
	print("BATTLE UI: USE POTION")
	print("Slot:", slot_index)
	print("================================")

	if current_player == null:

		print("No current player.")

		return

	if current_player.turn_manager == null:

		print("Player has no TurnManager.")

		return

	var turn_manager: TurnManager = (
		current_player.turn_manager
	)

	if turn_manager.current_state != (
		TurnManager.TurnState.PLAYER_TURN
	):

		print(
			"Cannot use potion. Current state:",
			turn_manager.current_state
		)

		return

	var success := await turn_manager.use_player_potion(
		slot_index
	)

	if not success:

		print(
			"Potion use failed."
		)

		return

	item_bag_panel.hide()
	_refresh_item_bag()


# ==================================================
# Helpers
# ==================================================

func _clear_optional_moves():

	move3_button.text = "Empty"
	move4_button.text = "Empty"

	move3_button.disabled = true
	move4_button.disabled = true


func _exit_tree():
	print("BattleUI exiting tree")

	if GameEvents.animal_hp_changed.is_connected(update_hp):
		GameEvents.animal_hp_changed.disconnect(update_hp)

	if GameEvents.moves_updated.is_connected(setup_moves):
		GameEvents.moves_updated.disconnect(setup_moves)

	if GameEvents.battle_names_updated.is_connected(setup_names):
		GameEvents.battle_names_updated.disconnect(setup_names)

	if GameEvents.status_changed.is_connected(update_status_labels):
		GameEvents.status_changed.disconnect(update_status_labels)

	if GameEvents.battle_initialized.is_connected(setup_battle_ui):
		GameEvents.battle_initialized.disconnect(setup_battle_ui)

	if GameEvents.request_target_selection.is_connected(show_target_selection):
		GameEvents.request_target_selection.disconnect(show_target_selection)

	if GameEvents.target_selected.is_connected(_on_target_selected):
		GameEvents.target_selected.disconnect(_on_target_selected)

	if GameEvents.turn_changed.is_connected(_on_turn_changed):
		GameEvents.turn_changed.disconnect(_on_turn_changed)

	if GameEvents.potion_effects_changed.is_connected(update_potion_effects):
		GameEvents.potion_effects_changed.disconnect(update_potion_effects)
