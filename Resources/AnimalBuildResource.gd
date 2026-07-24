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


# --------------------------------------------------
# Final Stats
# --------------------------------------------------

var final_hp:int = 100
var final_attack:int = 10
var final_defense:int = 0
var final_speed:int = 10



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

	# Calculate final stats
	if animal != null:

		final_hp = animal.base_hp + hp_bonus
		final_attack = animal.base_attack + attack_bonus
		final_defense = animal.base_defense + defense_bonus
		final_speed = animal.base_speed + speed_bonus


func clear_build():
	genes.clear()
	moves.clear()
	calculate_stats()


func can_add_gene(gene:GeneResource) -> bool:
	return used_adaptations + gene.adaptation_cost <= adaptation_limit
