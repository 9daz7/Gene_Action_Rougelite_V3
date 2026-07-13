extends Resource
class_name EnemyResource

enum EnemyType {
	NORMAL,
	ELITE,
	BOSS
}

@export var enemy_name: String = ""
@export_multiline var description: String = ""

@export var enemy_type: EnemyType = EnemyType.NORMAL

# Base stats
@export var base_hp: int = 100
@export var base_attack: int = 5
@export var base_speed: int = 10

# Genes enemies start with
@export var starting_genes: Array[GeneResource] = []

# Genes that can be discovered
@export var drop_gene_pool: Array[GeneResource] = []

@export var sprite: Texture2D
