extends Resource
class_name LegendaryMutation

@export var mutation_name := ""

@export var required_gene_1: GeneResource
@export var required_gene_2: GeneResource

@export var bonus_passives: Array[PassiveEffect] = []

@export var bonus_moves: Array[MoveResource] = []
