extends Control

signal gene_chosen(gene: GeneResource)

var options: Array[GeneResource] = []

@onready var container = $VBoxContainer

func show_choices(genes: Array[GeneResource]):
	options = genes
	show()
	
	var buttons = container.get_children()

	for i in range(buttons.size()):
		var btn = buttons[i]

		if i < genes.size():
			btn.text = genes[i].gene_name
			btn.show()

			# reconnect safely
			if not btn.pressed.is_connected(_on_button_pressed.bind(i)):
				btn.pressed.connect(_on_button_pressed.bind(i))
		else:
			btn.hide()


func _on_button_pressed(index: int):
	var gene = options[index]
	hide()
	gene_chosen.emit(gene)
