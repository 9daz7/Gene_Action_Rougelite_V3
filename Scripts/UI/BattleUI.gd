extends CanvasLayer


signal move_selected(move_index)


@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

var move_buttons:Array[Button]


func _ready():
	print("BattleUI ready")
	
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

	move3_button.disabled = true
	move4_button.disabled = true
	
	
func setup_moves(player):

	var moves = player.get_battle_moves()

	move3_button.text = "Empty"
	move4_button.text = "Empty"
	
	move3_button.disabled = true
	move4_button.disabled = true


	if moves.size() > 2:
		move3_button.text = moves[2].move_name
		move3_button.disabled = false


	if moves.size() > 3:
		move4_button.text = moves[3].move_name
		move4_button.disabled = false
		
		
func enable_moves():

	for button in move_buttons:
		button.disabled = false


func disable_moves():

	for button in move_buttons:
		button.disabled = true
