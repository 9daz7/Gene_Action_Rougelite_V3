extends CanvasLayer

signal move_selected(move_index)

@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

func _ready():
	print("BattleUI ready")
	
	attack_button.pressed.connect(
		func():
			print("Attack button pressed")
			move_selected.emit(0)
			print("Emit finished")
	)
	
	protect_button.pressed.connect(
		func():
			print("Protect button pressed")
			move_selected.emit(1)
	)
	
	move3_button.disabled = true
	move4_button.disabled = true
