extends Control
class_name LabHub


# ==================================================
# Signals
# ==================================================

signal start_run_requested
signal build_confirmed(build: AnimalBuildResource)
#signal lab_closed


# ==================================================
# Onready Variables
# ==================================================

@onready var start_button = $StartRunButton
@onready var animal_button = $AnimalButton
@onready var animal_creation: AnimalCreationUI = $AnimalCreationUI
@onready var gene_storage_label: Label = $GeneStorageLabel


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	_setup_connections()

	animal_creation.hide()

	_update_gene_storage_label()


# ==================================================
# Setup
# ==================================================

func setup(
	new_run_manager: RunManager,
	new_gene_database: GeneDatabase
) -> void:

	animal_creation.setup(
		new_run_manager,
		new_gene_database
	)


# ==================================================
# Public Functions
# ==================================================


func open() -> void:

	print("Lab Hub opened")

	_update_gene_storage_label()

	show()


func close() -> void:

	hide()
	
	
# ==================================================
# Private Functions
# ==================================================


func _setup_connections() -> void:

	if not start_button.pressed.is_connected(
		_on_start_run_pressed
	):

		start_button.pressed.connect(
			_on_start_run_pressed
		)

	if not animal_button.pressed.is_connected(
		_open_animal_creation
	):

		animal_button.pressed.connect(
			_open_animal_creation
		)

	if not animal_creation.build_confirmed.is_connected(
		_on_build_confirmed
	):

		animal_creation.build_confirmed.connect(
			_on_build_confirmed
		)

	if not PermanentProgressionManager.gene_storage_changed.is_connected(
		_update_gene_storage_label
	):

		PermanentProgressionManager.gene_storage_changed.connect(
			_update_gene_storage_label
		)


# ==================================================
# Gene Storage
# ==================================================

func _update_gene_storage_label() -> void:

	if gene_storage_label == null:
		return

	var used := (
		PermanentProgressionManager.get_gene_storage_used()
	)

	var capacity := (
		PermanentProgressionManager.get_gene_storage_capacity()
	)

	gene_storage_label.text = (
		"Gene Storage: "
		+ str(used)
		+ " / "
		+ str(capacity)
	)


# ==================================================
# Animal Creation
# ==================================================


func _open_animal_creation() -> void:

	print("Opening animal creation")

	animal_creation.open()


func _on_build_confirmed(
	build: AnimalBuildResource
) -> void:

	print(
		"LabHub received build:",
		build.animal_name
	)

	build_confirmed.emit(build)

	animal_creation.close()

	#close()
#
	#lab_closed.emit()


# ==================================================
# Run
# ==================================================

func _on_start_run_pressed() -> void:

	print("LabHub requesting run start")

	start_run_requested.emit()
