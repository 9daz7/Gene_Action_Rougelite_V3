extends Node2D
class_name HubWorld


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0

@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0


# ==================================================
# Signals
# ==================================================

signal animal_lab_requested
#signal start_run_requested
#signal build_confirmed(build: AnimalBuildResource)

var is_open := false

# ==================================================
# Onready Variables
# ==================================================

@onready var animal_lab: Interactable = $AnimalLab/Interactable
#@onready var animal_creation_ui: AnimalCreationUI = (
	#$CanvasLayer/AnimalCreationUI
#)


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	print("================================")
	print("HUB WORLD READY")
	print("================================")

	_connect_interactions()

	#animal_creation_ui.hide()


# ==================================================
# Setup
# ==================================================


func setup(
	new_run_manager: RunManager,
	new_gene_database: GeneDatabase
) -> void:

	#animal_creation_ui.setup(
		#new_run_manager,
		#new_gene_database
	#)

	print("HubWorld setup complete")


# ==================================================
# Public Functions
# ==================================================


func open() -> void:

	print("================================")
	print("OPENING HUB WORLD")
	print("================================")

	is_open = true

	process_mode = Node.PROCESS_MODE_INHERIT

	show()

	var hub_player := get_node_or_null("HubPlayer")

	if hub_player != null:

		hub_player.process_mode = Node.PROCESS_MODE_INHERIT
		hub_player.show()

		print("HubPlayer enabled and shown.")

	if animal_lab != null:

		animal_lab.monitoring = true
		animal_lab.monitorable = true

	print("HubWorld visible", visible)


func close() -> void:

	print("================================")
	print("CLOSING HUB WORLD")
	print("================================")

	is_open = false

	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

	var hub_player := get_node_or_null("HubPlayer")

	if hub_player != null:

		hub_player.process_mode = Node.PROCESS_MODE_DISABLED
		hub_player.hide()

		if hub_player is HubPlayer:
			hub_player.set_nearby_interactable(null)

		print("HubPlayer disabled and hidden.")

	if animal_lab != null:

		animal_lab.monitoring = false
		animal_lab.monitorable = false

	print("HubWorld visible:", visible)
	print("HubWorld process mode:", process_mode)


# ==================================================
# Interaction Connections
# ==================================================

func _connect_interactions() -> void:

	if animal_lab == null:

		push_error(
			"HubWorld: AnimalLab Interactable not found."
		)

		return

	if not animal_lab.interacted.is_connected(
		_on_animal_lab_interacted
	):

		animal_lab.interacted.connect(
			_on_animal_lab_interacted
		)

	#if not animal_lab.lab_opened.is_connected(
		#_on_animal_lab_opened
	#):
#
		#animal_lab.lab_opened.connect(
			#_on_animal_lab_opened
		#)
#
	#if not animal_creation_ui.build_confirmed.is_connected(
		#_on_build_confirmed
	#):
#
		#animal_creation_ui.build_confirmed.connect(
			#_on_build_confirmed
		#)


# ==================================================
# Animal Lab
# ==================================================

func _on_animal_lab_interacted() -> void:

	print("================================")
	print("OPENING ANIMAL LAB")
	print("================================")

	animal_lab_requested.emit()
#
	##animal_creation_ui.open()
## ==================================================
## Animal Lab
## ==================================================
#
#func _on_animal_lab_opened() -> void:
#
	#print("================================")
	#print("HUB WORLD: OPENING ANIMAL LAB")
	#print("================================")
#
	#animal_lab_requested.emit()
#
## ==================================================
## Animal Creation
## ==================================================
#
#func _on_build_confirmed(
	#build: AnimalBuildResource
#) -> void:
#
	#print(
		#"HubWorld received animal build:",
		#build.animal_name
	#)
#
	#build_confirmed.emit(build)
	#
