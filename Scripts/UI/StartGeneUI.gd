extends Control


@onready var screen = $GeneSelectionScreen


func open(database):
	screen.open(database)

	screen.genes_selected.connect(func(genes):
		emit_signal("genes_selected", genes)
	)
