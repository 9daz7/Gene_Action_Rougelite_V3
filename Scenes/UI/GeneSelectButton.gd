extends Button


var gene:GeneResource

signal gene_selected(gene)

func setup(g):
	gene = g
	text = (
		gene.gene_name
		+ " - "
		+ gene.get_rarity_name()
	)
	
	
func _pressed():
	
	print(
		"BUTTON CLICKED:",
		gene.gene_name
	)
	
	gene_selected.emit(gene)
	
