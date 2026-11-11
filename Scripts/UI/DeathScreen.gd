extends Control

signal return_home_requested


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()

	$Content/Panel/ReturnHomeButton.pressed.connect(
		_on_return_home_pressed
	)


func open() -> void:

	show()


func _on_return_home_pressed() -> void:

	return_home_requested.emit()
