extends Control
class_name RestRoom


signal rest_finished


@onready var heal_button = $CenterContainer/VBoxContainer/HealButton
@onready var leave_button = $CenterContainer/VBoxContainer/LeaveButton


@onready var run_manager = $"../../RunManager"


var healed := false


func _ready():

	heal_button.pressed.connect(
		_heal_pressed
	)

	leave_button.pressed.connect(
		_leave_pressed
	)


func open():
	show()
	healed = false


func _heal_pressed():
	if healed:
		return

	var heal_amount = int(run_manager.max_hp * 0.35)

	run_manager.heal_player(heal_amount)

	healed = true
	print("Rest healed player")

	heal_button.disabled = true


func _leave_pressed():
	rest_finished.emit()
	queue_free()
