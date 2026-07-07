extends Control


signal genes_selected(genes:Array[Gene])


@onready var gene_screen = $GeneSelectionScreen



func open(database):

	show()

	gene_screen.open(database)


	if not gene_screen.genes_selected.is_connected(
		_on_genes_selected
	):
		gene_screen.genes_selected.connect(
			_on_genes_selected
		)



func _on_genes_selected(genes):

	genes_selected.emit(genes)
