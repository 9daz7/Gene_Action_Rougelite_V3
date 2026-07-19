extends Control
class_name GeneLoadoutScreen


signal loadout_confirmed(genes: Array[GeneResource])


# Genes currently displayed on screen
var options: Array[GeneResource] = []


# Player's chosen genes
var selected_genes: Array[GeneResource] = []


const MAX_ADAPTATION := 6

var current_adaptation := 0


@onready var container = $VBoxContainer
@onready var start_button = $StartButton
@onready var adaptation_label = $AdaptationLabel


func open(owned_genes: Array[GeneResource]):
	
	print("!!! GENE LOADOUT OPENED !!!")
	print("Called from:")
	print(get_stack())
	
	show()

	options = owned_genes
	
	selected_genes.clear()

	current_adaptation = 0
	
	update_adaptation()
	
	display_choices(options)


func display_choices(genes: Array[GeneResource]):
	var buttons = container.get_children()

	for i in range(buttons.size()):
		var btn = buttons[i]

		if i < genes.size():
			btn.text = (
				genes[i].gene_name
				+ " ("
				+ str(genes[i].adaptation_cost)
				+ ")"
			)
			btn.show()

			# Avoid duplicate connections
			if not btn.pressed.is_connected(_on_button_pressed):
				
				btn.pressed.connect(
					_on_button_pressed.bind(i)
				)

		else:
			btn.hide()


func _on_button_pressed(index: int):
	var gene = options[index]

	# Remove gene
	if gene in selected_genes:
		selected_genes.erase(gene)
		current_adaptation -= gene.adaptation_cost
		print("Removed:", gene.gene_name)
		
		update_adaptation()

		return


	# Maximum reached
	if current_adaptation + gene.adaptation_cost > MAX_ADAPTATION:
		print("Not enough adaptation slots")

		return


	selected_genes.append(gene)
	current_adaptation += gene.adaptation_cost
	print("Selected:", gene.gene_name)
	
	update_adaptation()
	
	
func update_adaptation():
	adaptation_label.text = (
		"Adaptation: "
		+ str(current_adaptation)
		+ " / "
		+ str(MAX_ADAPTATION)
	)

	start_button.disabled = selected_genes.is_empty()
	
	
func _on_start_button_pressed():
	if selected_genes.is_empty():
		print("Choose at least one gene")

		return


	print("Starting genes:")

	for gene in selected_genes:
		print(gene.gene_name)

	hide()

	loadout_confirmed.emit(selected_genes)
