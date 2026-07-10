extends Control


signal genes_selected(genes:Array[GeneResource])


# Genes currently displayed on screen
var options:Array[GeneResource] = []

# Player's chosen genes
var selected_genes:Array[GeneResource] = []

const MAX_SELECTED_GENES := 3

@onready var container = $VBoxContainer
@onready var start_button = $StartButton



func open(genes:Array[GeneResource]):
	show()
	options = genes
	selected_genes.clear()
	display_choices(options)



func display_choices(genes:Array[GeneResource]):

	var buttons = container.get_children()

	for i in range(buttons.size()):

		var btn = buttons[i]

		if i < genes.size():
			btn.text = genes[i].gene_name
			btn.show()


			# avoid duplicate connections
			if not btn.pressed.is_connected(_on_button_pressed):

				btn.pressed.connect(
					_on_button_pressed.bind(i)
				)
		else:
			btn.hide()


func _on_button_pressed(index:int):

	var gene = options[index]

	# clicking again removes the gene
	if gene in selected_genes:

		selected_genes.erase(gene)
		print("Removed:", gene.gene_name)

		return


	# maximum reached
	if selected_genes.size() >= MAX_SELECTED_GENES:
		print("Maximum genes selected")
		
		return


	selected_genes.append(gene)

	print("Selected:", gene.gene_name)


func _on_start_button_pressed():

	if selected_genes.size() != MAX_SELECTED_GENES:
		print("Select", MAX_SELECTED_GENES, "genes before starting")
		
		return


	print("Starting genes:")

	for gene in selected_genes:
		print(gene.gene_name)

	hide()

	genes_selected.emit(selected_genes)
