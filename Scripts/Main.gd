extends Node

@onready var run_manager = $RunManager
@onready var gene_database = $GeneDatabase
@onready var battle_manager = $BattleManager


@onready var start_gene_ui = $UI/StartGeneUI
@onready var battle_ui = $UI/BattleUI



func _ready():

	gene_database.load_genes()

	start_gene_ui.genes_selected.connect(
		start_run
	)

	start_gene_ui.open(gene_database)



func start_run(selected_genes:Array[Gene]):

	start_gene_ui.hide()

	battle_ui.show()


	run_manager.setup_run(selected_genes)


	start_battle()



func start_battle():

	battle_manager.start_battle()
	
