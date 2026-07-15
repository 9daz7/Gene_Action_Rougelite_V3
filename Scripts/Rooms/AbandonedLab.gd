extends Control
class_name AbandonedLab


signal lab_finished


@export var lab_data: LabResource

@onready var status_label = $VBoxContainer/LabStatusLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

@onready var edit_gene_button = $VBoxContainer/OperationContainer/EditGeneButton
@onready var upgrade_gene_button = $VBoxContainer/OperationContainer/UpgradeGeneButton
@onready var extract_gene_button = $VBoxContainer/OperationContainer/ExtractGeneButton
@onready var edit_mutagen_button = $VBoxContainer/OperationContainer/EditMutagenButton
@onready var upgrade_mutagen_button = $VBoxContainer/OperationContainer/UpgradeMutagenButton

@onready var continue_button = $VBoxContainer/ContinueButton


var lab_action_used := false
var experiment_available := false

var critical_battle_complete := false

var battle_manager


# -------------------------------------------------------------------
# Initialization
# -------------------------------------------------------------------

	
func open(data:LabResource):

	lab_data = data

	show()
	
	lab_action_used = false
	experiment_available = false
	critical_battle_complete = false
	
	battle_manager = get_tree().current_scene.get_node("Managers/BattleManager")
	
	print(
		"Opened lab:",
		LabResource.LabStatus.keys()[lab_data.lab_status]
	)

	setup_lab()

	match lab_data.lab_status:

		LabResource.LabStatus.CRITICAL:
			start_critical_lab()

		_:
			reset_buttons()
			check_experiment()
	

func start_critical_lab():

	print("Critical containment failure")

	disable_operations()
	
	continue_button.disabled = true

	battle_manager.start_critical_experiment()
	
	
func _ready():

	battle_manager = get_tree().current_scene.get_node("Managers/BattleManager")

	battle_manager.battle_won.connect(
		_on_experiment_won
	)
	
	edit_gene_button.pressed.connect(
		func():
			use_lab_action("edit_gene")
	)

	upgrade_gene_button.pressed.connect(
		func():
			use_lab_action("upgrade_gene")
	)

	extract_gene_button.pressed.connect(
		func():
			use_lab_action("extract_gene")
	)

	edit_mutagen_button.pressed.connect(
		func():
			use_lab_action("edit_mutagen")
	)

	upgrade_mutagen_button.pressed.connect(
		func():
			use_lab_action("upgrade_mutagen")
	)
	
	continue_button.pressed.connect(
		_on_continue_pressed
	)


func _on_experiment_won(enemy):

	if lab_data.lab_status != LabResource.LabStatus.CRITICAL:
		return

	print("Critical experiment defeated")

	critical_battle_won()
	

func _on_continue_pressed():
	print("Leaving laboratory")

	lab_finished.emit()
	
	
# -------------------------------------------------------------------
# Lab Setup
# -------------------------------------------------------------------
	
func setup_lab():
	match lab_data.lab_status:
		LabResource.LabStatus.STABLE:
			status_label.text = "Laboratory Status: Stable"

			description_label.text = \
			"The equipment is still functional."

		LabResource.LabStatus.UNSTABLE:
			status_label.text = "Laboratory Status: Unstable"

			description_label.text = \
			"Warning: Mutation instability detected."

		LabResource.LabStatus.CRITICAL:
			status_label.text = "Laboratory Status: Critical"

			description_label.text = \
			"Containment failure detected."
			
			
func reset_buttons():
	edit_gene_button.disabled = false
	upgrade_gene_button.disabled = false
	extract_gene_button.disabled = true
	edit_mutagen_button.disabled = false
	upgrade_mutagen_button.disabled = false
	
	print("LAB BUTTON RESET")
	print("Edit Gene disabled:", edit_gene_button.disabled)
	print("Upgrade Gene disabled:", upgrade_gene_button.disabled)
	print("Edit Mutagen disabled:", edit_mutagen_button.disabled)
	print("Upgrade Mutagen disabled:", upgrade_mutagen_button.disabled)
			
			
func check_experiment():
	if randf() <= lab_data.experiment_chance:
		experiment_available = true

		extract_gene_button.disabled = false

	else:
		experiment_available = false

		extract_gene_button.disabled = true
		
		
func critical_battle_won():
	critical_battle_complete = true

	print("Epic experiment gene recovered")

	reset_buttons()
	
	continue_button.disabled = false
		
# -------------------------------------------------------------------
# Lab Actions
# -------------------------------------------------------------------
	
func use_lab_action(action:String):
	if lab_action_used:
		return

	lab_action_used = true

	match action:
		"edit_gene":
			print("Gene modification complete")
			#edit_gene() use these for post demo 

		"upgrade_gene":
			print("Gene upgraded")
			#upgrade_gene()

		"extract_gene":
			print("Experiment gene extracted.")
			#extract_gene()

		"edit_mutagen":
			print("Mutagen formula altered")
			#edit_mutagen()

		"upgrade_mutagen":
			print("Mutagen potency increased")
			#upgrade_mutagen()


	disable_operations()
	
	
func disable_operations():

	edit_gene_button.disabled = true
	upgrade_gene_button.disabled = true
	extract_gene_button.disabled = true
	edit_mutagen_button.disabled = true
	upgrade_mutagen_button.disabled = true
	
	
func close():
	hide()
