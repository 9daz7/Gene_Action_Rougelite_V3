extends AnimalBase
class_name PlayerAnimal


func start_battle():

	print("Player ready")
	
	setup_basic_moves()
	
	var chameleon = preload("res://Data/Genes/ChameleonSkin.tres")

	add_gene(chameleon)
	
#func test_gene():
	#
	#var gene = preload("res://Data/Genes/TigerStrenghtGene.tres")
	#
	#add_gene(gene)
	#print("Current genes:")
	#
	#for g in equipped_genes:
		#print(g.gene_name)
	#
	#print("Current moves:")
	#
	#for move in learned_moves:
		#print(move.move_name)
		
