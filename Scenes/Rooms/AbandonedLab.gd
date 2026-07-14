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


# -------------------------------------------------------------------
# Initialization
# -------------------------------------------------------------------

func open(data:LabResource):
	lab_data = data

	show()

	lab_action_used = false
	experiment_available = false

	reset_buttons()
	
	setup_lab()
	check_experiment()
	
	#
	# for when critical lab is ready
	#
#func open(data:LabResource):
#
	#lab_data = data
#
	#show()
#
	#match lab_data.lab_status:
#
		#LabResource.LabStatus.CRITICAL:
			#start_critical_battle()
#
		#_:
			#setup_lab()
			#check_experiment()
	
	
func _ready():

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
			
			
func check_experiment():
	if randf() <= lab_data.experiment_chance:
		experiment_available = true

		extract_gene_button.disabled = false

	else:
		experiment_available = false

		extract_gene_button.disabled = true
		
		
# -------------------------------------------------------------------
# Lab Actions
# -------------------------------------------------------------------
	
func use_lab_action(action:String):
	if lab_action_used:
		return

	lab_action_used = true

	match action:
		"edit_gene":
			print("Editing gene")
			#edit_gene()

		"upgrade_gene":
			print("Upgrading gene")
			#upgrade_gene()

		"extract_gene":
			print("Extracting gene")
			#extract_gene()

		"edit_mutagen":
			print("Editing mutagen")
			#edit_mutagen()

		"upgrade_mutagen":
			print("Upgrading mutagen")
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
