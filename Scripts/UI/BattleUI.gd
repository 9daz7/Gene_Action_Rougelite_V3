extends CanvasLayer
class_name BattleUI


# ==================================================
# Signals
# ==================================================


# ==================================================
# Onready Variables
# ==================================================

@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

@onready var player_name_label = $PlayerPanel/PlayerNameLabel
@onready var enemy_name_label = $EnemyPanel/EnemyNameLabel

@onready var player_status_label = $PlayerPanel/PlayerStatusLabel
@onready var enemy_status_label = $EnemyPanel/EnemyStatusLabel


# ==================================================
# Member Variables
# ==================================================


var move_buttons:Array[Button] = []


# ==================================================
# Initialization
# ==================================================


func _ready():
	print("BattleUI ready")

	_setup_buttons()

	
	if not GameEvents.hp_changed.is_connected(update_player_hp):

		GameEvents.hp_changed.connect(
			update_player_hp
		)

	if not GameEvents.moves_updated.is_connected(setup_moves):

		GameEvents.moves_updated.connect(
			setup_moves
		)

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


# ==================================================
# Public Functions
# ==================================================


func setup_names(
		player: PlayerAnimal,
		enemy: EnemyAnimal
	):

	if player:
		player_name_label.text = player.get_display_name()

	if enemy:
		enemy_name_label.text = enemy.get_display_name()


func setup_moves(player):

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
		
		
func update_status_labels(player:AnimalBase, enemy:AnimalBase):

	player_status_label.text = get_status_text(player)
	
	if enemy != null:
		enemy_status_label.text = get_status_text(enemy)
	else:
		enemy_status_label.text = ""


func get_status_text(animal:AnimalBase) -> String:

	var text := ""

	for effect in animal.status_effects:

		text += effect.effect_name
		text += " (" + str(effect.duration) + ")\n"

	return text


func setup_battle_ui(player, enemies):

	var enemy = enemies[0]

	setup_names(
		player,
		enemy
	)

	print("Battle UI initialized")


func update_player_hp(current_hp:int, max_hp:int):

	print(
		"BattleUI HP UPDATE:",
		current_hp,
		"/",
		max_hp
	)

	# player_hp_bar.value = current_hp
	# player_hp_label.text = str(current_hp) + "/" + str(max_hp)
	
	
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
			GameEvents.move_selected.emit(0)
	)


	protect_button.pressed.connect(
		func():
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

	if GameEvents.hp_changed.is_connected(update_player_hp):

		GameEvents.hp_changed.disconnect(update_player_hp)

	if GameEvents.battle_names_updated.is_connected(
		setup_names
	):

		GameEvents.battle_names_updated.disconnect(
			setup_names
		)
