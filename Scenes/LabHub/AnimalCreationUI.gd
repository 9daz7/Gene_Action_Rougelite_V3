extends Control


signal build_confirmed(build:AnimalBuildResource)


@onready var run_manager = $"../../../Managers/RunManager"
@onready var gene_database = $"../../../Managers/GeneDatabase"

@onready var confirm_button = $ConfirmButton
@onready var cancel_button = $CancelButton
@onready var animal_name = $AnimalName


var owned_genes:Array[GeneResource] = []
var selected_genes:Array[GeneResource] = []
var available_moves:Array[MoveResource] = []
var selected_moves:Array[MoveResource] = []


const MAX_GENES := 6
const MAX_MOVES := 2


const GENE_BUTTON = preload("res://Scenes/UI/GeneSelectButton.tscn")

@onready var gene_container = ($GeneSelection/GeneList/GeneContainer)

const MOVE_BUTTON = preload("res://Scenes/UI/MoveSelectButton.tscn")

@onready var move_container = $MoveSelection/AvailabelMoves/MoveContainer


func _ready():

	print("Gene container:", gene_container)
	print("Gene button scene:", GENE_BUTTON)
	
	print("AnimalCreationUI ready")

	print("Confirm:", confirm_button)
	print("Cancel:", cancel_button)
	print("Name:", animal_name)
	
	confirm_button.pressed.connect(
		_confirm_build
	)

	cancel_button.pressed.connect(
		_cancel
	)


func open():
	
	selected_genes.clear()
	selected_moves.clear()
	available_moves.clear()

	print("Animal creation opened")
	
	load_owned_genes()
	load_gene_buttons()
	
	show()


func load_owned_genes():
	owned_genes.clear()
	owned_genes = run_manager.gene_collection

	print("Owned genes:")

	for gene in owned_genes:

		print(
			gene.gene_name,
			"|",
			gene.get_rarity_name()
		)
		

func load_gene_buttons():

	print(
		"Gene container:",
		gene_container
	)

	print(
		"Owned gene count:",
		owned_genes.size()
	)
	
	print("Loading gene buttons")
	
	for child in gene_container.get_children():
		child.queue_free()

	for gene in owned_genes:
		var button = GENE_BUTTON.instantiate()
		gene_container.add_child(button)

		button.setup(gene)
		button.gene_selected.connect(
			_on_gene_selected
		)

		print(
			"Created:",
			button.text,
			" Position:",
			button.position
		)
		

func _on_gene_selected(gene:GeneResource):

	if selected_genes.has(gene):
		print("Already selected")
		return

	if selected_genes.size() >= MAX_GENES:
		print("Maximum genes reached")
		return

	selected_genes.append(gene)

	print(
		"Selected gene:",
		gene.gene_name
	)

	update_moves()


func load_move_buttons():

	for child in move_container.get_children():
		child.queue_free()

	for move in available_moves:

		var button = MOVE_BUTTON.instantiate()

		move_container.add_child(button)

		button.setup(move)

		button.move_selected.connect(_on_move_selected)

func _on_move_selected(move:MoveResource):
	
	if selected_moves.has(move):
		print("Already selected")
		return

	if selected_moves.size() >= MAX_MOVES:
		print("Maximum moves selected")
		return

	selected_moves.append(move)

	print("Selected move:", move.move_name)
	
	
func update_moves():
	available_moves.clear()

	for gene in selected_genes:
		for move in gene.move_pool:
			if not available_moves.has(move):
				available_moves.append(move)

	print("Available moves:")

	for move in available_moves:
		print(move.move_name)
		
	load_move_buttons()


func close():
	hide()


func _confirm_build():

	print("Creating animal build")

	var build = AnimalBuildResource.new()

	build.animal_name = animal_name.text

	if build.animal_name == "":
		build.animal_name = "Deebo"


	build.animal = preload("res://Data/Animals/Dog.tres")

	build.genes = selected_genes.duplicate()
	build.moves = selected_moves.duplicate()

	build.calculate_stats()

	print("Created build:",build.animal_name)
	print("Genes:",build.genes.size())
	print("Moves:",build.moves.size())

	build_confirmed.emit(build)
	close()


func _cancel():
	close()
