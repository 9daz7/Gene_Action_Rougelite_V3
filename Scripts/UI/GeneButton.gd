extends Button

signal gene_pressed(gene)

var gene:GeneResource

func setup(g:GeneResource):
	gene = g
	text = gene.gene_name
	
func _pressed():
	gene_pressed.emit(gene)
	
