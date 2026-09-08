extends Control
class_name AbandonedLab_UI


# ==================================================
# Signals
# ==================================================

signal lab_finished


# ==================================================
# Managers
# ==================================================

@onready var room_manager: RoomManager = get_node(
	"../../Managers/RoomManager"
)

@onready var run_manager: RunManager = get_node(
	"../../Managers/RunManager"
)

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../../Managers/RunMutagenManager"
)


# ==================================================
# Constants
# ==================================================

const MUTAGEN_MANAGEMENT_SCENE = preload(
	"res://Scenes/Rooms/MutagenManagementUI.tscn"
)


# ==================================================
# Lab Data
# ==================================================

@export var lab_data: LabResource


# ==================================================
# UI
# ==================================================

@onready var status_label: Label = (
	$VBoxContainer/LabStatusLabel
)

@onready var description_label: Label = (
	$VBoxContainer/DescriptionLabel
)

@onready var edit_mutagen_button: Button = (
	$VBoxContainer/OperationContainer/EditMutagenButton
)

@onready var heal_button: Button = (
	$VBoxContainer/OperationContainer/HealButton
)

@onready var continue_button: Button = (
	$VBoxContainer/ContinueButton
)


# ==================================================
# Runtime References
# ==================================================

var battle_manager: BattleManager = null

var mutagen_management_ui: MutagenManagementUI = null

var connected_to_battle: bool = false

var critical_battle_active: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	_connect_buttons()


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

	show()


	# ==================================================
	# Current Room
	# ==================================================

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	# ==================================================
	# Debug State
	# ==================================================

	print(
		"Opened lab:",
		LabResource.LabStatus.keys()[
			lab_data.lab_status
		]
	)

	print(
		"Battle completed:",
		current_room.lab_battle_completed
	)

	print(
		"Mutagen editing completed:",
		current_room.lab_mutagen_editing_completed
	)

	print(
		"Healing used:",
		current_room.lab_healing_used
	)

	print(
		"Pending reward:",
		current_room.pending_lab_mutagen_reward
	)


	# ==================================================
	# Setup
	# ==================================================

	setup_lab()

	_update_lab_state()


	# ==================================================
	# Critical Lab
	# ==================================================

	if (
		lab_data.lab_status
		== LabResource.LabStatus.CRITICAL
	):

		if not current_room.lab_battle_completed:

			_connect_critical_battle_signal()

			start_critical_lab()


# ==================================================
# Close
# ==================================================

func close() -> void:

	print(
		"Closing abandoned lab"
	)

	critical_battle_active = false

	# ==================================================
	# Close Management UI
	# ==================================================

	if is_instance_valid(
		mutagen_management_ui
	):

		mutagen_management_ui.queue_free()

	mutagen_management_ui = null

	# ==================================================
	# Disconnect Battle Signal
	# ==================================================

	_disconnect_critical_battle_signal()

	# ==================================================
	# Clear References
	# ==================================================

	lab_data = null

	battle_manager = null

	hide()


# ==================================================
# Current Room
# ==================================================

func _get_current_room() -> RoomResource:

	if room_manager == null:

		push_error(
			"AbandonedLab_UI: RoomManager is missing."
		)

		return null

	return room_manager.current_room


# ==================================================
# Critical Battle Signal
# ==================================================

func _connect_critical_battle_signal() -> void:

	if GameEvents.battle_won.is_connected(
		_on_experiment_won
	):

		connected_to_battle = true

		return


	GameEvents.battle_won.connect(
		_on_experiment_won
	)

	connected_to_battle = true


func _disconnect_critical_battle_signal() -> void:

	if not connected_to_battle:

		return


	if GameEvents.battle_won.is_connected(
		_on_experiment_won
	):

		GameEvents.battle_won.disconnect(
			_on_experiment_won
		)

	connected_to_battle = false


# ==================================================
# Critical Lab
# ==================================================

func start_critical_lab() -> void:

	print("================================")
	print("CRITICAL LAB")
	print("Containment failure!")
	print("================================")


	if battle_manager == null:

		push_error(
			"AbandonedLab_UI: BattleManager is missing."
		)

		return


	edit_mutagen_button.disabled = true
	heal_button.disabled = true
	continue_button.disabled = true

	# --------------------------------------------------
	# Mark critical battle as active
	# --------------------------------------------------

	critical_battle_active = true

	# Prevent this UI from blocking BattleUI input.
	hide()

	battle_manager.start_critical_experiment()


# ==================================================
# Critical Experiment Won
# ==================================================

func _on_experiment_won(enemy) -> void:

	# --------------------------------------------------
	# Ignore unrelated battles
	# --------------------------------------------------

	if not critical_battle_active:

		return

	print(
		"AbandonedLab received battle win"
	)

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return

	if lab_data == null:

		return

	if (
		lab_data.lab_status
		!= LabResource.LabStatus.CRITICAL
	):

		print(
			"Ignoring battle win because Lab is not critical."
		)

		return

	if current_room.lab_battle_completed:

		print(
			"Critical Lab battle already completed."
		)

		return

	print(
		"Critical experiment defeated"
	)

	critical_battle_active = false

	critical_battle_won()


# ==================================================
# Critical Battle Won
# ==================================================

func critical_battle_won() -> void:

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	# ==================================================
	# Save Battle Completion
	# ==================================================

	current_room.lab_battle_completed = true


	print("================================")
	print("CRITICAL LAB: BATTLE WON")
	print("================================")


	# ==================================================
	# Generate Reward
	# ==================================================

	if current_room.pending_lab_mutagen_reward == null:

		var reward: MutagenResource = (
			run_mutagen_manager.add_critical_lab_reward()
		)

		current_room.pending_lab_mutagen_reward = reward

		if reward != null:

			print(
				"Critical Lab reward stored:",
				reward.mutagen_name
			)

		else:

			print(
				"Critical Lab produced no eligible Mutagen."
			)

	else:

		print(
			"Critical Lab already has a pending reward."
		)


	# ==================================================
	# Disconnect Battle Signal
	# ==================================================

	_disconnect_critical_battle_signal()


	# ==================================================
	# Return To Lab
	# ==================================================

	show()

	_update_lab_state()


# ==================================================
# Lab State
# ==================================================

func _update_lab_state() -> void:

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	# ==================================================
	# Heal
	# ==================================================

	heal_button.disabled = (
		current_room.lab_healing_used
	)


	# ==================================================
	# Mutagen Management
	# ==================================================

	edit_mutagen_button.disabled = (
		current_room.lab_mutagen_editing_completed
	)


	# ==================================================
	# Critical Reward Debug
	# ==================================================

	if current_room.pending_lab_mutagen_reward != null:

		print(
			"Pending Lab reward:",
			current_room.pending_lab_mutagen_reward.mutagen_name
		)


	# ==================================================
	# Leave
	# ==================================================

	continue_button.disabled = false


# ==================================================
# Lab Setup
# ==================================================

func setup_lab() -> void:

	if lab_data == null:

		return


	match lab_data.lab_status:


		LabResource.LabStatus.STABLE:

			status_label.text = (
				"Laboratory Status: Stable"
			)

			description_label.text = (
				"The equipment is still functional."
			)

			edit_mutagen_button.text = (
				"Extract Mutagen"
			)


		LabResource.LabStatus.UNSTABLE:

			status_label.text = (
				"Laboratory Status: Unstable"
			)

			description_label.text = (
				"Warning: Mutation instability detected."
			)

			edit_mutagen_button.text = (
				"Manage Mutagens"
			)


		LabResource.LabStatus.CRITICAL:

			status_label.text = (
				"Laboratory Status: Critical"
			)

			description_label.text = (
				"Containment failure detected."
			)

			edit_mutagen_button.text = (
				"Manage Mutagens"
			)


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


		_:

			push_error(
				"AbandonedLab_UI: Unknown Lab action: "
				+ action
			)


# ==================================================
# Mutagen Management
# ==================================================

func open_mutagen_management() -> void:

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	# Management permanently locked after Confirm.
	if current_room.lab_mutagen_editing_completed:

		print(
			"Mutagen management already confirmed."
		)

		return


	if is_instance_valid(
		mutagen_management_ui
	):

		return


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

		return


	get_tree().current_scene.get_node(
		"UI"
	).add_child(
		mutagen_management_ui
	)


	mutagen_management_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	# ==================================================
	# Leave
	# ==================================================

	if not mutagen_management_ui.management_finished.is_connected(
		_on_mutagen_management_finished
	):

		mutagen_management_ui.management_finished.connect(
			_on_mutagen_management_finished
		)


	# ==================================================
	# Confirm
	# ==================================================

	if not mutagen_management_ui.management_confirmed.is_connected(
		_on_mutagen_management_confirmed
	):

		mutagen_management_ui.management_confirmed.connect(
			_on_mutagen_management_confirmed
		)


	# ==================================================
	# Open
	# ==================================================

	mutagen_management_ui.open(
		current_room.pending_lab_mutagen_reward
	)


# ==================================================
# Management - Leave
# ==================================================

func _on_mutagen_management_finished() -> void:

	print(
		"Returned from Mutagen management without confirmation."
	)


	if is_instance_valid(
		mutagen_management_ui
	):

		mutagen_management_ui.queue_free()


	mutagen_management_ui = null


	# Nothing was committed.
	# Management remains available.
	_update_lab_state()


# ==================================================
# Management - Confirm
# ==================================================

func _on_mutagen_management_confirmed(
	new_equipped: Array[MutagenResource],
	new_reserve: MutagenResource,
	accepted_reward: bool
) -> void:

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	print("================================")
	print("MUTAGEN BUILD COMMITTED")
	print("================================")


	# ==================================================
	# Commit Equipped
	# ==================================================

	run_mutagen_manager.equipped_mutagens = (
		new_equipped.duplicate()
	)


	# ==================================================
	# Commit Reserve
	# ==================================================

	run_mutagen_manager.reserve_mutagen = (
		new_reserve
	)


	# ==================================================
	# Notify Mutagen System
	# ==================================================

	run_mutagen_manager.mutagens_changed.emit()


	# ==================================================
	# Reward
	# ==================================================

	if accepted_reward:

		print(
			"Critical Lab reward accepted."
		)

	else:

		print(
			"Critical Lab reward skipped."
		)


	# The reward is no longer pending after
	# management is confirmed.
	current_room.pending_lab_mutagen_reward = null


	# ==================================================
	# Permanently Lock Management
	# ==================================================

	current_room.lab_mutagen_editing_completed = true


	# ==================================================
	# Close Management UI
	# ==================================================

	if is_instance_valid(
		mutagen_management_ui
	):

		mutagen_management_ui.queue_free()


	mutagen_management_ui = null


	_update_lab_state()


# ==================================================
# Healing
# ==================================================

func heal_player() -> void:

	var current_room: RoomResource = (
		_get_current_room()
	)

	if current_room == null:

		return


	if current_room.lab_healing_used:

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


	current_room.lab_healing_used = true


	print(
		"Lab healed player for:",
		heal_amount
	)


	_update_lab_state()


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


# ==================================================
# Mutagen Button
# ==================================================

func _on_edit_mutagen_pressed() -> void:

	use_lab_action(
		"edit_mutagen"
	)


# ==================================================
# Heal Button
# ==================================================

func _on_heal_pressed() -> void:

	use_lab_action(
		"heal"
	)


# ==================================================
# Leave Button
# ==================================================

func _on_continue_pressed() -> void:

	print(
		"Leaving laboratory"
	)

	lab_finished.emit()
