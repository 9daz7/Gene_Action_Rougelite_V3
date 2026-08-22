extends Control
class_name AbandonedLab_UI


# ==================================================
# Signals
# ==================================================

signal lab_finished


# ==================================================
# Export Variables
# ==================================================

@export var lab_data: LabResource


# ==================================================
# Onready Variables
# ==================================================

@onready var status_label = $VBoxContainer/LabStatusLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

@onready var edit_gene_button = $VBoxContainer/OperationContainer/EditGeneButton
@onready var upgrade_gene_button = $VBoxContainer/OperationContainer/UpgradeGeneButton
@onready var extract_gene_button = $VBoxContainer/OperationContainer/ExtractGeneButton

@onready var edit_mutagen_button = $VBoxContainer/OperationContainer/EditMutagenButton
@onready var upgrade_mutagen_button = $VBoxContainer/OperationContainer/UpgradeMutagenButton

@onready var continue_button = $VBoxContainer/ContinueButton


# ==================================================
# Member Variables
# ==================================================

var battle_manager: BattleManager = null

var lab_action_used: bool = false
var experiment_available: bool = false

var critical_battle_complete: bool = false

var connected_to_battle: bool = false
var lab_completed: bool = false


# ==================================================
# Initialization
# ==================================================


func _ready():
	
	_connect_buttons()


# ==================================================
# Public Functions
# ==================================================


func open(
	data: LabResource,
	manager: BattleManager
) -> void:

	if data == null:

		push_error(
			"AbandonedLab_UI: LabResource is missing."
		)

		return

	if manager == null:

		push_error(
			"AbandonedLab_UI: BattleManager is missing."
		)

		return

	lab_data = data
	battle_manager = manager

	lab_completed = false

	show()

	lab_action_used = false
	experiment_available = false

	if lab_data.lab_status != LabResource.LabStatus.CRITICAL:
		critical_battle_complete = false

	if lab_data.lab_status == LabResource.LabStatus.CRITICAL:
		
		if not GameEvents.battle_won.is_connected(
			_on_experiment_won
		):
			
			GameEvents.battle_won.connect(
				_on_experiment_won
			)
			
			connected_to_battle = true
	
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


func close():

	print("Closing abandoned lab")

	if connected_to_battle:

		if GameEvents.battle_won.is_connected(
			_on_experiment_won
		):

			GameEvents.battle_won.disconnect(
				_on_experiment_won
			)

		connected_to_battle = false

	lab_data = null
	battle_manager = null

	critical_battle_complete = false
	experiment_available = false
	lab_action_used = false

	hide()


# ==================================================
# Critical Experiment
# ==================================================


func start_critical_lab() -> void:

	print("Critical containment failure")

	disable_operations()

	continue_button.disabled = true

	battle_manager.start_critical_experiment()


func _on_experiment_won(enemy) -> void:

	print("AbandonedLab received battle win")

	if lab_data == null:
		return

	if lab_data.lab_status != LabResource.LabStatus.CRITICAL:
		
		print("Ignoring because lab is not critical")
		
		return

	print("Critical experiment defeated")

	critical_battle_won()


func critical_battle_won() -> void:

	critical_battle_complete = true

	print(
		"Epic experiment gene recovered"
	)

		# permanently complete lab
	lab_data.lab_status = LabResource.LabStatus.STABLE

	reset_buttons()

	continue_button.disabled = false
	
	#if connected_to_battle:
#
		#if battle_manager.battle_won.is_connected(
			#_on_experiment_won
		#):
#
			#battle_manager.battle_won.disconnect(
				#_on_experiment_won
			#)
#
#
		#connected_to_battle = false


#func _on_continue_pressed():
	#
	#if connected_to_battle:
		#
		#battle_manager.battle_won.disconnect(_on_experiment_won)
		#connected_to_battle = false
	#
	#print("Leaving laboratory")
#
	#lab_finished.emit()


# ==================================================
# Lab Setup
# ==================================================


func setup_lab():

	match lab_data.lab_status:

		LabResource.LabStatus.STABLE:

			status_label.text = "Laboratory Status: Stable"

			description_label.text = (
			"The equipment is still functional."
			)


		LabResource.LabStatus.UNSTABLE:

			status_label.text = "Laboratory Status: Unstable"

			description_label.text = (
			"Warning: Mutation instability detected."
			)


		LabResource.LabStatus.CRITICAL:

			status_label.text = "Laboratory Status: Critical"

			description_label.text = (
			"Containment failure detected."
			)


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


# ==================================================
# Lab Actions
# ==================================================


func use_lab_action(action:String):
	
	if lab_action_used:
		return

	lab_action_used = true

	match action:

		"edit_gene":

			print("Gene modification complete")


		"upgrade_gene":

			print("Gene upgraded")


		"extract_gene":

			print("Experiment gene extracted.")


		"edit_mutagen":

			print("Mutagen formula altered")


		"upgrade_mutagen":

			print("Mutagen potency increased")


	disable_operations()


func disable_operations():

	edit_gene_button.disabled = true
	upgrade_gene_button.disabled = true

	extract_gene_button.disabled = true

	edit_mutagen_button.disabled = true
	upgrade_mutagen_button.disabled = true


# ==================================================
# Private Functions
# ==================================================


func _connect_buttons() -> void:

	if not edit_gene_button.pressed.is_connected(
		_on_edit_gene_pressed
	):

		edit_gene_button.pressed.connect(
			_on_edit_gene_pressed
	)

	if not upgrade_gene_button.pressed.is_connected(
		_on_upgrade_gene_pressed
	):

		upgrade_gene_button.pressed.connect(
			_on_upgrade_gene_pressed
	)

	if not extract_gene_button.pressed.is_connected(
		_on_extract_gene_pressed
	):

		extract_gene_button.pressed.connect(
			_on_extract_gene_pressed
	)

	if not edit_mutagen_button.pressed.is_connected(
		_on_edit_mutagen_pressed
	):

		edit_mutagen_button.pressed.connect(
			_on_edit_mutagen_pressed
	)

	if not upgrade_mutagen_button.pressed.is_connected(
		_on_upgrade_mutagen_pressed
	):

		upgrade_mutagen_button.pressed.connect(
			_on_upgrade_mutagen_pressed
	)

	if not continue_button.pressed.is_connected(
		_on_continue_pressed
	):

		continue_button.pressed.connect(
			_on_continue_pressed
	)


func _on_edit_gene_pressed() -> void:

	use_lab_action("edit_gene")


func _on_upgrade_gene_pressed() -> void:

	use_lab_action("upgrade_gene")


func _on_extract_gene_pressed() -> void:

	use_lab_action("extract_gene")


func _on_edit_mutagen_pressed() -> void:

	use_lab_action("edit_mutagen")


func _on_upgrade_mutagen_pressed() -> void:

	use_lab_action("upgrade_mutagen")

#
	#if not continue_button.pressed.is_connected(
		#_on_continue_pressed
	#):
#
		#continue_button.pressed.connect(
			#_on_continue_pressed
	#)
#
	#edit_gene_button.pressed.connect(
		#func():
			#use_lab_action("edit_gene")
	#)
#
	#upgrade_gene_button.pressed.connect(
		#func():
			#use_lab_action("upgrade_gene")
	#)
#
	#extract_gene_button.pressed.connect(
		#func():
			#use_lab_action("extract_gene")
	#)
#
	#edit_mutagen_button.pressed.connect(
		#func():
			#use_lab_action("edit_mutagen")
	#)
#
	#upgrade_mutagen_button.pressed.connect(
		#func():
			#use_lab_action("upgrade_mutagen")
	#)
#
	#continue_button.pressed.connect(
		#_on_continue_pressed
	#)


func _on_continue_pressed() -> void:

	if lab_completed:

		return

	lab_completed = true

	continue_button.disabled = true

	print(
		"Leaving laboratory"
	)

	lab_finished.emit()
