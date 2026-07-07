extends Control


signal genes_selected(genes:Array[GeneResource])


var options: Array[GeneResource] = []


@onready var container = $VBoxContainer


func open(database):

	show()

	var choices = database.get_random_genes(3)

	display_choices(choices)



func display_choices(genes:Array[GeneResource]):

	options = genes

	var buttons = container.get_children()

	for i in range(buttons.size()):

		var btn = buttons[i]

		if i < genes.size():

			btn.text = genes[i].gene_name
			btn.show()

			if not btn.pressed.is_connected(_on_button_pressed.bind(i)):
				btn.pressed.connect(_on_button_pressed.bind(i))

		else:
			btn.hide()



func _on_button_pressed(index:int):

	var selected_gene = options[index]

	hide()

	genes_selected.emit([selected_gene])
