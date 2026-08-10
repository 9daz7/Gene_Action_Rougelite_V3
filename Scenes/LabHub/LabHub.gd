extends Control
class_name LabHub


# ==================================================
# Signals
# ==================================================

signal start_run_requested


# ==================================================
# Onready Variables
# ==================================================

@onready var start_button = $StartRunButton
@onready var animal_button = $AnimalButton
@onready var run_manager = $"../../Managers/RunManager"
@onready var animal_creation = $AnimalCreationUI


# ==================================================
# Initialization
# ==================================================

func _ready():

	_connect_buttons()
	animal_creation.hide()


# ==================================================
# Public Functions
# ==================================================


func open():
	print("Lab Hub opened")
	show()


func close():
	hide()
	
	
# ==================================================
# Private Functions
# ==================================================


func _connect_buttons():

	start_button.pressed.connect(
		_on_start_run_pressed
	)

	animal_button.pressed.connect(
		_open_animal_creation
	)

	animal_creation.build_confirmed.connect(
		_on_build_confirmed
	)


func _open_animal_creation():

	print("Opening animal creation")
	animal_creation.open()


func _on_start_run_pressed():
	
	print("LabHub requesting run start")
	start_run_requested.emit()
	
	
func _on_build_confirmed(build):

	print(
		"Saving animal:",
		build.animal_name
	)

	run_manager.set_animal_build(build)
