extends Control
class_name InteractionPrompt

# ==================================================
# Onready Variables
# ==================================================

@onready var label: Label = $Label


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	hide()


# ==================================================
# Public Functions
# ==================================================

func show_prompt(text: String = "E  Interact") -> void:

	label.text = text

	show()


func hide_prompt() -> void:

	hide()
