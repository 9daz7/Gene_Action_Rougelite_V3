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
@onready var enemy_status_label = $EnemyPanel/EnemyStatusLabel


# ==================================================
# Member Variables
# ==================================================


var move_buttons:Array[Button] = []

var enemy_ui := {}

var selecting_target := false


# ==================================================
# Initialization
# ==================================================


func _ready():
	print("BattleUI ready")

	_setup_buttons()

	
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


func setup_names(
		player: PlayerAnimal,
		enemies:Array
	):

	if player:
		player_name_label.text = (
			player.get_display_name()
		)

	#if enemies.is_empty():
#
		#enemy_name_label.text = ""
#
		#return
#
		#var enemy_text := ""
#
		#for enemy in enemies:
#
			#if enemy:
#
				#enemy_text += (
				#enemy.get_display_name()
				#+ "\n"
			#)


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

	#var text := ""
#
	#for enemy in enemies:
#
		#if enemy:
#
			#text += (
				#enemy.name
				#+ ": "
				#+ get_status_text(enemy)
				#+ "\n"
			#)
#
	#enemy_status_label.text = text


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
