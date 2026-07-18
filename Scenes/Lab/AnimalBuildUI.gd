extends Control
class_name AnimalBuildUI


signal build_confirmed(build)

@onready var name_input = $VBoxContainer/AnimalNameInput

@onready var gene_list = $VBoxContainer/GeneList

@onready var selected_label = $VBoxContainer/SelectedGenesLabel

@onready var confirm_button = $VBoxContainer/ConfirmButton


var owned_genes:Array[GeneResource] = []

var selected_genes:Array[GeneResource] = []
