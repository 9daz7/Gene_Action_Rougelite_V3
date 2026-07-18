extends Resource
class_name AnimalBuildResource


# --------------------------------------------------
# Identity
# --------------------------------------------------

@export var animal_name:String = "Deebo"
@export var animal:AnimalResource

# --------------------------------------------------
# Build Data
# --------------------------------------------------

@export var genes:Array[GeneResource] = []
@export var moves:Array[MoveResource] = []

# --------------------------------------------------
# Adaptations
# --------------------------------------------------

@export var adaptation_limit := 6
var used_adaptations := 0


# --------------------------------------------------
# Calculated Stats
# --------------------------------------------------

@export var hp_bonus:int = 0
@export var attack_bonus = 0
@export var defense_bonus:int = 0
@export var speed_bonus:int = 0



func calculate_stats():

	hp_bonus = 0
	attack_bonus = 0
	defense_bonus = 0
	speed_bonus = 0
	used_adaptations = 0
	
	for gene in genes:
		hp_bonus += gene.hp_bonus
		attack_bonus += gene.attack_bonus
		defense_bonus += gene.defense_bonus
		speed_bonus += gene.speed_bonus
		used_adaptations += gene.adaptation_cost
		
		
func clear_build():
	genes.clear()
	moves.clear()
	calculate_stats()
	
	
func can_add_gene(gene:GeneResource) -> bool:
	return used_adaptations + gene.adaptation_cost <= adaptation_limit
	
