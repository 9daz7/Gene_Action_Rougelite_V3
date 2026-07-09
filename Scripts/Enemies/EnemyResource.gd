extends Resource
class_name EnemyResource

@export var enemy_name : String = ""

# base stats
@export var base_hp : int = 100
@export var base_attack : int = 10
@export var base_speed : int = 10

# genes enemies start with
@export var starting_genes : Array[GeneResource] = []

# genes that can be discovered
@export var drop_gene_pool : Array[GeneResource] = []

@export var sprite : Texture2D
