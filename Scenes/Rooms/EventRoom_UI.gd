extends Control
class_name EventRoom_UI


# ==================================================
# Signals
# ==================================================

signal event_finished


# ==================================================
# Onready Variables
# ==================================================

@onready var continue_button: Button = ($VBoxContainer/ContinueButton)


# ==================================================
# Member Variables
# ==================================================

var run_manager: RunManager = null
var event_completed: bool = false


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	if not continue_button.pressed.is_connected(
		_on_continue_pressed
	):

		continue_button.pressed.connect(
			_on_continue_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(
	manager: RunManager
) -> void:

	run_manager = manager
	event_completed = false

	show()

	continue_button.disabled = false


func close() -> void:

	hide()



# ==================================================
# Event
# ==================================================

func _on_continue_pressed() -> void:

	if event_completed:

		return

	event_completed = true
	continue_button.disabled = true

	print(
		"EVENT UI: CONTINUE PRESSED"
	)

	event_finished.emit()
