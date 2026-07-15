extends Resource
class_name LabResource


enum LabStatus
{
	STABLE,
	UNSTABLE,
	CRITICAL
}


@export var lab_name: String = "Abandoned Laboratory"


@export var lab_status: LabStatus = LabStatus.STABLE

# chance for lab test subject
@export var experiment_chance: float = 0.25

# Chance experiment attacks when extracting gene
@export var hostile_experiment_chance: float = 0.0

# Gene rarity from extraction
@export var experiment_gene_rarity: GeneResource.Rarity
