extends Control
class_name AbandonedLab_UI


# ==================================================
# Signals
# ==================================================

signal lab_finished


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = get_node(
	"../../Managers/RunManager"
)

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../../Managers/RunMutagenManager"
)

#@onready var mutagen_database: MutagenDatabase = get_node(
	#"../../Managers/MutagenDatabase"
#)


# ==================================================
# Constants
# ==================================================

const MUTAGEN_MANAGEMENT_SCENE = preload(
	"res://Scenes/Rooms/MutagenManagementUI.tscn"
)


# ==================================================
# Export Variables
# ==================================================

@export var lab_data: LabResource


# ==================================================
# Onready Variables
# ==================================================

@onready var status_label = $VBoxContainer/LabStatusLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

#@onready var edit_gene_button = $VBoxContainer/OperationContainer/EditGeneButton
#@onready var upgrade_gene_button = $VBoxContainer/OperationContainer/UpgradeGeneButton
#@onready var extract_gene_button = $VBoxContainer/OperationContainer/ExtractGeneButton

@onready var edit_mutagen_button = ($VBoxContainer/OperationContainer/EditMutagenButton)
#@onready var upgrade_mutagen_button = $VBoxContainer/OperationContainer/UpgradeMutagenButton
@onready var heal_button = ($VBoxContainer/OperationContainer/HealButton)

@onready var continue_button = $VBoxContainer/ContinueButton


# ==================================================
# Member Variables
# ==================================================

var battle_manager: BattleManager = null
var mutagen_management_ui: MutagenManagementUI = null

var mutagen_management_used: bool = false
var healing_used: bool = false

#var experiment_available: bool = false
var critical_battle_complete: bool = false
var connected_to_battle: bool = false

var lab_completed: bool = false

var pending_critical_reward: MutagenResource = null

var reward_confirmation_dialog: ConfirmationDialog = null


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	_connect_buttons()

	reward_confirmation_dialog = ConfirmationDialog.new()

	reward_confirmation_dialog.title = (
		"Replace Reserve Mutagen?"
	)

	reward_confirmation_dialog.confirmed.connect(
		_on_replace_reserve_confirmed
	)

	reward_confirmation_dialog.canceled.connect(
		_on_replace_reserve_canceled
	)

	add_child(
		reward_confirmation_dialog
	)


# ==================================================
# Reset Lab Actions
# ==================================================

func reset_lab_actions() -> void:

	mutagen_management_used = false
	healing_used = false


# ==================================================
# Open
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

	reset_lab_actions()

	critical_battle_complete = false

	show()

	# ==================================================
	# Critical Lab
	# ==================================================

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
		LabResource.LabStatus.keys()[
			lab_data.lab_status
		]
	)

	setup_lab()

	match lab_data.lab_status:

		LabResource.LabStatus.CRITICAL:

			start_critical_lab()

		_:

			reset_buttons()


# ==================================================
# Close
# ==================================================

func close() -> void:

	print(
		"Closing abandoned lab"
	)

	if is_instance_valid(
		mutagen_management_ui
	):

		mutagen_management_ui.queue_free()

	mutagen_management_ui = null

	if connected_to_battle:

		if GameEvents.battle_won.is_connected(
			_on_experiment_won
		):

			GameEvents.battle_won.disconnect(
				_on_experiment_won
			)

		connected_to_battle = false

	if is_instance_valid(
		reward_confirmation_dialog
	):

		reward_confirmation_dialog.hide()

	lab_data = null
	battle_manager = null

	critical_battle_complete = false

	reset_lab_actions()

	hide()


# ==================================================
# Critical Lab
# ==================================================

func start_critical_lab() -> void:

	print("================================")
	print("CRITICAL LAB")
	print("Containment failure!")
	print("================================")

	disable_operations()

	continue_button.disabled = true

	hide()

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

	if critical_battle_complete:
		return

	critical_battle_complete = true

	print("================================")
	print("CRITICAL LAB: BATTLE WON")
	print("================================")

	show()

	# ==================================================
	# Generate Reward
	# ==================================================

	var reward: MutagenResource = (
		run_mutagen_manager.add_critical_lab_reward()
	)

	if reward == null:

		status_label.text = (
			"Containment stabilized.\n"
			+ "No eligible Critical Lab Mutagen available."
		)

		reset_buttons()

		return

	# ==================================================
	# Equipped Slot Available
	# ==================================================

	if not run_mutagen_manager.is_full():

		if run_mutagen_manager.add_mutagen(
			reward
		):

			status_label.text = (
				"Containment stabilized.\n"
				+ "Recovered Mutagen:\n"
				+ reward.mutagen_name
			)

			reset_buttons()

			return

	# ==================================================
	# Equipped Full / Reserve Empty
	# ==================================================

	if not run_mutagen_manager.has_reserve():

		if run_mutagen_manager.set_reserve_mutagen(
			reward
		):

			status_label.text = (
				"Containment stabilized.\n"
				+ "Recovered Mutagen placed in reserve:\n"
				+ reward.mutagen_name
			)

			reset_buttons()

			return

	# ==================================================
	# Equipped + Reserve Full
	# ==================================================

	pending_critical_reward = reward

	_show_reward_replacement_confirmation()


func _show_reward_replacement_confirmation() -> void:

	if pending_critical_reward == null:

		return

	var current_reserve: MutagenResource = (
		run_mutagen_manager.reserve_mutagen
	)

	if current_reserve == null:

		push_error(
			"AbandonedLab_UI: Expected reserve Mutagen but none exists."
		)

		pending_critical_reward = null

		return

	reward_confirmation_dialog.dialog_text = (
		"Your Mutagen slots are full.\n\n"
		+ "Replace your reserve Mutagen?\n\n"
		+ "Current Reserve:\n"
		+ current_reserve.mutagen_name
		+ "\n\n"
		+ "New Mutagen:\n"
		+ pending_critical_reward.mutagen_name
	)

	reward_confirmation_dialog.ok_button_text = (
		"Replace Reserve"
	)

	reward_confirmation_dialog.cancel_button_text = (
		"Skip Reward"
	)

	reward_confirmation_dialog.popup_centered()


func _on_replace_reserve_confirmed() -> void:

	if pending_critical_reward == null:

		return

	var reward: MutagenResource = (
		pending_critical_reward
	)

	var old_reserve: MutagenResource = (
		run_mutagen_manager.replace_reserve_mutagen(
			reward
		)
	)

	if old_reserve != null:

		status_label.text = (
			"Containment stabilized.\n"
			+ "Reserve Mutagen replaced.\n\n"
			+ "Recovered Mutagen:\n"
			+ reward.mutagen_name
		)

	else:

		status_label.text = (
			"Containment stabilized.\n"
			+ "Recovered Mutagen:\n"
			+ reward.mutagen_name
		)

	pending_critical_reward = null

	reset_buttons()


func _on_replace_reserve_canceled() -> void:

	print(
		"Critical Lab reward skipped:",
		pending_critical_reward.mutagen_name
		if pending_critical_reward != null
		else "Unknown"
	)

	status_label.text = (
		"Containment stabilized.\n"
		+ "Mutagen reward skipped."
	)

	pending_critical_reward = null

	reset_buttons()

# ==================================================
# Critical Mutagen Reward
# ==================================================

#func get_critical_mutagen_reward() -> MutagenResource:
#
	#if mutagen_database == null:
#
		#push_error(
			#"AbandonedLab_UI: MutagenDatabase not found."
		#)
#
		#return null
#
#
	#if run_manager == null:
#
		#push_error(
			#"AbandonedLab_UI: RunManager not found."
		#)
#
		#return null
#
#
	#var available: Array[MutagenResource] = (
		#mutagen_database.get_mutagens_for_world(
			#run_manager.current_world
		#)
	#)
#
	#var candidates: Array[MutagenResource] = []
#
	#for mutagen in available:
#
		#if mutagen == null:
			#continue
#
		## ==================================================
		## Critical Labs give Tier 3 Mutagens
		## ==================================================
#
		#if mutagen.tier != (
			#MutagenResource.MutagenTier.TIER_3
		#):
#
			#continue
#
		## ==================================================
		## Don't reward an already equipped Mutagen
		## ==================================================
#
		#if run_manager.run_mutagens.has(
			#mutagen
		#):
#
			#continue
#
		#candidates.append(
			#mutagen
		#)
#
	#if candidates.is_empty():
#
		#print(
			#"No Tier 3 Mutagen available for Critical Lab."
		#)
#
		#return null
#
	#var reward: MutagenResource = (
		#candidates.pick_random()
	#)
#
	#print(
		#"Critical Lab selected Mutagen:",
		#reward.mutagen_name
	#)
#
	#return reward


# ==================================================
# Lab Setup
# ==================================================

func setup_lab() -> void:

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


# ==================================================
# Buttons
# ==================================================

func reset_buttons() -> void:

	edit_mutagen_button.disabled = (mutagen_management_used)

	heal_button.disabled = (healing_used)

	continue_button.disabled = false


func disable_operations() -> void:

	edit_mutagen_button.disabled = true
	heal_button.disabled = true


# ==================================================
# Lab Actions
# ==================================================

func use_lab_action(
	action: String
) -> void:

	match action:

		"edit_mutagen":

			open_mutagen_management()


		"heal":

			heal_player()


func open_mutagen_management() -> void:

	if mutagen_management_used:
		return

	mutagen_management_used = true

	edit_mutagen_button.disabled = true

	print(
		"Opening Mutagen management."
	)

	mutagen_management_ui = (
		MUTAGEN_MANAGEMENT_SCENE.instantiate()
		as MutagenManagementUI
	)

	if mutagen_management_ui == null:

		push_error(
			"AbandonedLab_UI: Failed to create Mutagen Management UI."
		)

		edit_mutagen_button.disabled = false
		mutagen_management_used = false

		return

	get_tree().current_scene.get_node(
		"UI"
	).add_child(
		mutagen_management_ui
	)

	mutagen_management_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if not mutagen_management_ui.management_finished.is_connected(
		_on_mutagen_management_finished
	):

		mutagen_management_ui.management_finished.connect(
			_on_mutagen_management_finished
		)

	mutagen_management_ui.open()


func _on_mutagen_management_finished() -> void:

	print(
		"Returned from Mutagen management."
	)

	if is_instance_valid(
		mutagen_management_ui
	):

		mutagen_management_ui.queue_free()

	mutagen_management_ui = null

	edit_mutagen_button.disabled = true

	# Healing remains available.
	heal_button.disabled = healing_used


func heal_player() -> void:

	if healing_used:
		return

	if run_manager == null:

		push_error(
			"AbandonedLab_UI: RunManager not found."
		)

		return

	var heal_amount: int = int(
		run_manager.max_hp * 0.50
	)

	if heal_amount <= 0:
		return

	run_manager.heal_player(
		heal_amount
	)

	healing_used = true

	heal_button.disabled = true

	print(
		"Lab healed player for:",
		heal_amount
	)

# ==================================================
# Buttons
# ==================================================

func _connect_buttons() -> void:

	if not edit_mutagen_button.pressed.is_connected(
		_on_edit_mutagen_pressed
	):

		edit_mutagen_button.pressed.connect(
			_on_edit_mutagen_pressed
	)


	if not heal_button.pressed.is_connected(
		_on_heal_pressed
	):

		heal_button.pressed.connect(
			_on_heal_pressed
	)


	if not continue_button.pressed.is_connected(
		_on_continue_pressed
	):

		continue_button.pressed.connect(
			_on_continue_pressed
	)


func _on_edit_mutagen_pressed() -> void:

	use_lab_action(
		"edit_mutagen"
	)


func _on_heal_pressed() -> void:

	use_lab_action(
		"heal"
	)


func _on_continue_pressed() -> void:

	if lab_completed:
		return

	lab_completed = true

	continue_button.disabled = true

	print(
		"Leaving laboratory"
	)

	lab_finished.emit()
