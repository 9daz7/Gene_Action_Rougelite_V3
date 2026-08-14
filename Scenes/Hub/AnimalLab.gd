extends Node2D
class_name AnimalLab


# ==================================================
# Signals
# ==================================================

signal lab_opened
signal lab_closed


# ==================================================
# Onready Variables
# ==================================================

@onready var interactable: Interactable = $Interactable


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("AnimalLab ready")

	_connect_interaction()


# ==================================================
# Interaction
# ==================================================


func _connect_interaction() -> void:

	if interactable == null:

		push_error(
			"AnimalLab: Interactable not found."
		)

		return

	if not interactable.interacted.is_connected(
		_on_interacted
	):

		interactable.interacted.connect(
			_on_interacted
		)


func _on_interacted() -> void:

	print("Animal Lab interacted with")

	lab_opened.emit()


# ==================================================
# Public Functions
# ==================================================

func open() -> void:

	print("AnimalLab opened")

	lab_opened.emit()


func close() -> void:

	print("AnimalLab closed")

	lab_closed.emit()

## ==================================================
## Animal Creation
## ==================================================
#
#func open_animal_lab() -> void:
#
	#if animal_creation_ui == null:
#
		#print(
			#"ERROR: AnimalCreationUI is missing"
		#)
#
		#return
#
	#print(
		#"Opening Animal Creation UI"
	#)
#
	#animal_creation_ui.open()
#
	#lab_opened.emit()
#
#
## ==================================================
## Build Handling
## ==================================================
#
#func _on_build_confirmed(
	#build: AnimalBuildResource
#) -> void:
#
	#print(
		#"Animal Lab build confirmed:",
		#build.animal_name
	#)
#
	#print(
		#"Genes:",
		#build.genes.size()
	#)
#
	#print(
		#"Moves:",
		#build.moves.size()
	#)
#
	#animal_creation_ui.close()
#
	#lab_closed.emit()
