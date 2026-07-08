extends Control

signal move_selected(move_index)

@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

func _ready():
	attack_button.pressed.connect(
		func():
			print("Attack button pressed")
			move_selected.emit(0)
	)
	
	protect_button.pressed.connect(
		func():
			print("Protect button pressed")
			move_selected.emit(1)
	)
	
	move3_button.disabled = true
	move4_button.disabled = true
