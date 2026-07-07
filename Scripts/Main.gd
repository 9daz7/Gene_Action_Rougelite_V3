extends Node

@onready var managers = $Managers

@onready var battle_manager = $Managers/BattleManager
@onready var run_manager = $Managers/RunManager
@onready var map_manager = $Managers/MapManager
@onready var ui_manager = $Managers/UIManager
@onready var gene_database = $Managers/GeneDatabase

@onready var battle_ui = $UI/BattleUI
@onready var gene_selection = $UI/GeneSelectionUI

func _ready():

	gene_database.load_genes()

	gene_selection.genes_selected.connect(start_run)

	gene_selection.open(gene_database)


func start_run(selected_genes:Array[GeneResource]):

	gene_selection.hide()

	run_manager.setup_run(selected_genes)

	battle_manager.start_battle()
