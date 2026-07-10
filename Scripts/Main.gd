extends Node

@onready var managers = $Managers

@onready var battle_manager = $Managers/BattleManager
@onready var run_manager = $Managers/RunManager
@onready var map_manager = $Managers/MapManager
@onready var ui_manager = $Managers/UIManager
@onready var gene_database = $Managers/GeneDatabase
@onready var reward_manager = $Managers/RewardManager

@onready var gene_selection = $UI/GeneSelectionScreen

func _ready():
	gene_database.load_genes()
	
	gene_selection.genes_selected.connect(start_run)
	
	var choices = gene_database.get_random_genes(5)
	
	start_gene_selection()


func start_gene_selection():
	
	var gene_choices = gene_database.get_random_genes(5)
	
	print("Strating gene choices:")
	
	for gene in gene_choices:
		print(gene.gene_name)
		
	gene_selection.open(gene_choices)
	
	
func start_run(selected_genes:Array[GeneResource]):
	print("Starting run with genes:")

	for gene in selected_genes:
		print(gene.gene_name)

	run_manager.setup_run(selected_genes)

	battle_manager.start_battle()
	
	
func _on_battle_won(enemy):
	print("Battle won!")
	
	var rewards = reward_manager.generate_rewards(enemy)

	if rewards.discovered_gene.size() > 0:

		print("Gene discovered:", rewards.discovered_gene[0].gene_name)
		
	print("Mutagen choices:", rewards.mutagen_choices)

func _on_battle_lost():

	print("Run failed")
