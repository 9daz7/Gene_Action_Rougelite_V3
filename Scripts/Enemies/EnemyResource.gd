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


# ==================================================
# AI
# ==================================================

enum AIType {
	BASIC,
	AGGRESSIVE,
	DEFENSIVE,
	TACTICAL
}

@export var ai_type: AIType = AIType.BASIC


# ==================================================
# Base Stats
# ==================================================

@export var base_hp := 100
@export var base_attack := 5
@export var base_speed := 10

# ==================================================
# Genes
# ==================================================

# Genes enemies start with
@export var starting_genes: Array[GeneResource] = []

# ==================================================
# Moves
# ==================================================

# Moves enemies start with
@export var moves: Array[MoveResource] = []

# ==================================================
# Rewards
# ==================================================


# Genes that can be discovered
@export var drop_gene_pool: Array[GeneResource] = []

# ==================================================
# Visuals
# ==================================================

@export var sprite: Texture2D
