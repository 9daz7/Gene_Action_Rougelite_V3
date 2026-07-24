extends CanvasLayer
class_name BattleUI


# ==================================================
# Signals
# ==================================================

signal move_selected(move_index)


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

	GameEvents.hp_changed.connect(
		_on_hp_changed
	)

	#move_buttons = [
		#attack_button,
		#protect_button,
		#move3_button,
		#move4_button
		#]
#
	#attack_button.pressed.connect(
		#func():
			#move_selected.emit(0)
	#)
#
	#protect_button.pressed.connect(
		#func():
			#move_selected.emit(1)
	#)
	#
	#move3_button.pressed.connect(
		#func():
			#move_selected.emit(2)
	#)
#
	#move4_button.pressed.connect(
		#func():
			#move_selected.emit(3)
	#)
#
	#move3_button.disabled = true
	#move4_button.disabled = true
	
func _on_hp_changed(animal):

	print("HP updated:", animal.name)

	# later update progress bars here


# ==================================================
# Public Functions
# ==================================================


func setup_names(player, enemy):

	player_name_label.text = player.name
	enemy_name_label.text = enemy.name
	
	
func setup_moves(player):

	var moves = player.get_battle_moves()

	_clear_optional_moves()

	for i in range(moves.size()):

		if i >= move_buttons.size():
			break

		move_buttons[i].text = moves[i].move_name
		move_buttons[i].disabled = false


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
			move_selected.emit(0)
	)


	protect_button.pressed.connect(
		func():
			move_selected.emit(1)
	)


	move3_button.pressed.connect(
		func():
			move_selected.emit(2)
	)


	move4_button.pressed.connect(
		func():
			move_selected.emit(3)
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
