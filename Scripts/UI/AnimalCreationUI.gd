extends Control
class_name AnimalCreationUI


# ==================================================
# Signals
# ==================================================

signal build_confirmed(build:AnimalBuildResource)


# ==================================================
# Constants
# ==================================================

const MAX_GENES := 6
const MAX_MOVES := 1

const GENE_BUTTON = preload("res://Scenes/UI/GeneSelectButton.tscn")
const MOVE_BUTTON = preload("res://Scenes/UI/MoveSelectButton.tscn")

#const BUILD_SLOT = preload(
	#"res://Scenes/UI/BuildSlot.tscn"
#)
const BITE_MOVE: MoveResource = preload(
    "res://Data/Moves/Bite.tres"
)

const PROTECT_MOVE: MoveResource = preload(
    "res://Data/Moves/Protect.tres"
)


# ==================================================
# Onready Variables
# ==================================================

#@onready var run_manager = $"../../../Managers/RunManager"
#@onready var gene_database = $"../../../Managers/GeneDatabase"
var run_manager: RunManager
var gene_database: GeneDatabase

@onready var confirm_button = $Buttons/ConfirmButton
@onready var cancel_button = $Buttons/CancelButton
@onready var animal_name = $AnimalName

@onready var gene_container = $GeneSelection/GeneList/GeneContainer
@onready var move_container = $MoveSelection/AvailabelMoves/MoveContainer

@onready var gene_slots: GridContainer = (
	$AnimalBuildDisplay/GeneSlots
)

@onready var bite_slot: BuildSlot = (
	$AnimalBuildDisplay/MoveSlots/DefaultMoveSlots/BiteSlot
)

@onready var protect_slot: BuildSlot = (
	$AnimalBuildDisplay/MoveSlots/DefaultMoveSlots/ProtectSlot
)

@onready var gene_move_slot: BuildSlot = (
	$AnimalBuildDisplay/MoveSlots/GeneMoveSlot
)


# ==================================================
# Member Variables
# ==================================================

var owned_genes:Array[GeneResource] = []

var selected_genes:Array[GeneResource] = []

var available_moves:Array[MoveResource] = []

var selected_moves:Array[MoveResource] = []

var selected_default_move: MoveResource = BITE_MOVE


# ==================================================
# Initialization
# ==================================================


func _ready():

	_setup_build_slots()
	_setup_connections()

	hide()


# ==================================================
# Public Functions
# ==================================================


func setup(
	new_run_manager: RunManager,
	new_gene_database: GeneDatabase
) -> void:

	run_manager = new_run_manager
	gene_database = new_gene_database


func open():

	if run_manager == null:
		push_error(
			"AnimalCreationUI: RunManager has not been assigned."
		)
		return

	if gene_database == null:
		push_error(
			"AnimalCreationUI: GeneDatabase has not been assigned."
		)
		return

	selected_genes.clear()
	selected_moves.clear()
	available_moves.clear()

	selected_default_move = BITE_MOVE

	_clear_move_buttons()

	_load_owned_genes()

	var saved_build := run_manager.current_animal_build

	if saved_build != null:

		selected_genes = saved_build.genes.duplicate()
		selected_moves = saved_build.moves.duplicate()

		if saved_build.selected_default_move != null:
			selected_default_move = saved_build.selected_default_move

	update_availabe_moves()
	_build_gene_buttons()

	_refresh_gene_slots()
	_refresh_move_slots()

	show()


func close():

	hide()


# ==================================================
# Private Functions
# ==================================================

func _setup_connections():

	confirm_button.pressed.connect(
		_confirm_build
	)

	cancel_button.pressed.connect(
		_cancel
	)


func _load_owned_genes():

	owned_genes.clear()

	var permanent_genes: Array[GeneResource] = (
		PermanentProgressionManager.get_owned_genes(
			gene_database
		)
	)

	for gene in permanent_genes:

		owned_genes.append(gene)

		print(
			"Owned gene:",
			gene.gene_name,
			"x",
			PermanentProgressionManager.get_gene_count(gene)
		)

	print(
		"Owned genes loaded",
		owned_genes.size()
	)


func _build_gene_buttons():

	for child in gene_container.get_children():
		child.queue_free()

	for gene in owned_genes:
		var button = GENE_BUTTON.instantiate()

		gene_container.add_child(button)

		button.setup(gene)

		button.gene_selected.connect(
			_on_gene_selected
		)


func _build_move_buttons():

	for child in move_container.get_children():
		child.queue_free()

	for move in available_moves:
		var button = MOVE_BUTTON.instantiate()

		move_container.add_child(button)

		button.setup(move)

		button.move_selected.connect(
			_on_move_selected
		)


func _on_gene_selected(gene: GeneResource) -> void:

	# Toggle off an already selected gene.
	if selected_genes.has(gene):

		selected_genes.erase(gene)

		print("Deselected gene:", gene.gene_name)

		update_availabe_moves()
		_refresh_gene_slots()

		return

	# Enforce gene limit.
	if selected_genes.size() >= MAX_GENES:

		print("Maximum genes reached")
		return

	selected_genes.append(gene)

	print("Selected gene:", gene.gene_name)

	update_availabe_moves()
	_refresh_gene_slots()


func _on_default_move_selected(index: int) -> void:

	if index == 0:
		selected_default_move = BITE_MOVE

	elif index == 1:
		selected_default_move = PROTECT_MOVE

	_refresh_move_slots()

	print(
		"Selected default move:",
		selected_default_move.move_name
	)


func _on_move_selected(move: MoveResource) -> void:

	# Toggle off an already selected move.
	if selected_moves.has(move):

		selected_moves.erase(move)

		print("Deselected move:", move.move_name)

		_refresh_move_slots()
		return

	# Enforce move limit.
	if selected_moves.size() >= MAX_MOVES:

		print("Maximum moves selected")
		return

	selected_moves.append(move)

	print("Selected move:", move.move_name)

	_refresh_move_slots()


func _setup_build_slots() -> void:

	# Initialize gene slots.
	for i in range(MAX_GENES):

		var slot := gene_slots.get_child(i) as BuildSlot

		slot.setup(i)

		if not slot.slot_pressed.is_connected(
			_on_gene_slot_pressed
		):
			slot.slot_pressed.connect(
				_on_gene_slot_pressed
			)

	# Initialize default move slots.
	bite_slot.setup(0, BITE_MOVE)
	protect_slot.setup(1, PROTECT_MOVE)

	# Enable toggle behavior for default moves.
	bite_slot.toggle_mode = true
	protect_slot.toggle_mode = true

	# Initialize gene move slot.
	gene_move_slot.setup(0)

	# Connect default move selection.
	if not bite_slot.slot_pressed.is_connected(
		_on_default_move_selected
	):
		bite_slot.slot_pressed.connect(
			_on_default_move_selected
		)

	if not protect_slot.slot_pressed.is_connected(
		_on_default_move_selected
	):
		protect_slot.slot_pressed.connect(
			_on_default_move_selected
		)

	# Connect gene move removal.
	if not gene_move_slot.slot_pressed.is_connected(
		_on_move_slot_pressed
	):
		gene_move_slot.slot_pressed.connect(
			_on_move_slot_pressed
		)

	_refresh_move_slots()


func _on_gene_slot_pressed(index: int) -> void:

	if index < 0 or index >= selected_genes.size():
		return

	var gene := selected_genes[index]

	selected_genes.remove_at(index)

	print("Removed gene from slot:", gene.gene_name)

	update_availabe_moves()
	_refresh_gene_slots()


func _on_move_slot_pressed(_index: int) -> void:

	if selected_moves.is_empty():
		return

	var move := selected_moves[0]

	selected_moves.clear()

	print("Removed gene move:", move.move_name)

	_refresh_move_slots()


func update_availabe_moves() -> void:

	available_moves.clear()

	# Collect moves from all selected genes.
	for gene in selected_genes:

		for move in gene.move_pool:

			if not available_moves.has(move):
				available_moves.append(move)

	# Remove selected moves no longer provided
	# by any remaining gene.
	for i in range(selected_moves.size() - 1, -1, -1):

		var move := selected_moves[i]

		if not available_moves.has(move):

			print(
				"Removed unavailable move:",
				move.move_name
			)

			selected_moves.remove_at(i)

	_build_move_buttons()

	_refresh_gene_slots()
	_refresh_move_slots()


func _refresh_gene_slots() -> void:

	for i in range(MAX_GENES):

		var slot := gene_slots.get_child(i) as BuildSlot

		var gene: GeneResource = null

		if i < selected_genes.size():
			gene = selected_genes[i]

		slot.setup(i, gene)


func _refresh_move_slots() -> void:

	# Default moves are always displayed.
	bite_slot.setup(0, BITE_MOVE)
	protect_slot.setup(1, PROTECT_MOVE)

	# Gene move is displayed separately.
	var gene_move: MoveResource = null

	if not selected_moves.is_empty():
		gene_move = selected_moves[0]

	gene_move_slot.setup(0, gene_move)

	# Show which default move is selected.
	bite_slot.set_pressed_no_signal(
		selected_default_move == BITE_MOVE
	)

	protect_slot.set_pressed_no_signal(
		selected_default_move == PROTECT_MOVE
	)


func _confirm_build():

	var build := AnimalBuildResource.new()

	build.animal_name = "Deebo"
	build.animal = preload("res://Data/Animals/Deebo.tres")

	build.genes = selected_genes.duplicate()
	build.moves = selected_moves.duplicate()
	build.selected_default_move = selected_default_move

	build.calculate_stats()

	# Store the selected build.
	run_manager.set_animal_build(build)

	print("Created build:", build.animal_name)

	build_confirmed.emit(build)

	close()


func _cancel():
	
	close()


# ==================================================
# Helpers
# ==================================================


func _clear_move_buttons():

	for child in move_container.get_children():
		child.queue_free()
