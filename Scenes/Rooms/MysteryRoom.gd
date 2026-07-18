extends Control


signal mystery_finished

@onready var continue_button = $VBoxContainer/ContinueButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.disabled = false
	
func _on_continue_pressed():
	mystery_finished.emit()
