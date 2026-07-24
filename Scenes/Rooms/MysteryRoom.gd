extends Control
class_name MysteryRoom


# ==================================================
# Signals
# ==================================================

signal mystery_finished


# ==================================================
# Onready Variables
# ==================================================

@onready var continue_button = $VBoxContainer/ContinueButton


# ==================================================
# Initialization
# ==================================================


func _ready():
	continue_button.pressed.connect(_on_continue_pressed)


# ==================================================
# Public Functions
# ==================================================


func open():

	show()

	continue_button.disabled = false



func close():

	hide()


# ==================================================
# Private Functions
# ==================================================


func _on_continue_pressed():

	print("Mystery room complete")

	mystery_finished.emit()
