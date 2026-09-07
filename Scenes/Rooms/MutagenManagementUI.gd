extends Control
class_name MutagenManagementUI


# ==================================================
# Signals
# ==================================================

signal management_finished

signal management_confirmed(
	new_equipped,
	new_reserve,
	accepted_reward
)


# ==================================================
# Managers
# ==================================================

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../../Managers/RunMutagenManager"
)


# ==================================================
# Constants
# ==================================================

const EQUIPPED_SLOT_COUNT: int = 6


# ==================================================
# UI
# ==================================================

@onready var title_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/TitleLabel
)

@onready var recovered_container: VBoxContainer = (
	$CenterContainer/PanelContainer/VBoxContainer/RecoveredMutagenContainer
)

@onready var recovered_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/RecoveredMutagenContainer/RecoveredLabel
)

@onready var reward_button: MutagenDragSlot = (
	$CenterContainer/PanelContainer/VBoxContainer/RecoveredMutagenContainer/RewardSlot
)

@onready var equipped_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/EquippedContainer/EquippedLabel
)

@onready var equipped_grid: GridContainer = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/EquippedContainer/EquippedGrid
)

@onready var reserve_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/ReserveContainer/ReserveLabel
)

@onready var reserve_button: MutagenDragSlot = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/ReserveContainer/ReserveSlot
)

@onready var remove_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/RemoveContainer/RemoveLabel
)

@onready var remove_button: MutagenDragSlot = (
	$CenterContainer/PanelContainer/VBoxContainer/WorkspaceContainer/RemoveContainer/RemoveSlot
)

@onready var instructions_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/InstructionsLabel
)

@onready var confirm_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/ActionContainer/ConfirmButton
)

@onready var leave_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/ActionContainer/LeaveButton
)


# ==================================================
# Slot References
# ==================================================

var slot_buttons: Array[MutagenDragSlot] = []


# ==================================================
# Temporary Build
# ==================================================

var temp_equipped: Array[MutagenResource] = []

var temp_reserve: MutagenResource = null

var temp_remove: MutagenResource = null

var temp_reward: MutagenResource = null

var had_reward: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	_setup_slots()

	if not confirm_button.pressed.is_connected(
		_on_confirm_pressed
	):

		confirm_button.pressed.connect(
			_on_confirm_pressed
	)

	if not leave_button.pressed.is_connected(
		_on_leave_pressed
	):

		leave_button.pressed.connect(
			_on_leave_pressed
	)

	hide()


# ==================================================
# Setup Slots
# ==================================================

func _setup_slots() -> void:

	slot_buttons.clear()

	# ==================================================
	# Equipped Slots
	# ==================================================

	if equipped_grid.get_child_count() < EQUIPPED_SLOT_COUNT:

		push_error(
			"MutagenManagementUI: EquippedGrid must contain six slots."
		)

		return

	for i in range(EQUIPPED_SLOT_COUNT):

		var slot := (
			equipped_grid.get_child(i)
			as MutagenDragSlot
		)

		if slot == null:

			push_error(
				"MutagenManagementUI: Equipped slot "
				+ str(i)
				+ " is not a MutagenDragSlot."
			)

			return

		slot.slot_type = "equipped"
		slot.slot_index = i

		slot_buttons.append(
			slot
		)

	# ==================================================
	# Reserve
	# ==================================================

	if reserve_button == null:

		push_error(
			"MutagenManagementUI: ReserveButton is missing."
		)

		return

	reserve_button.slot_type = "reserve"
	reserve_button.slot_index = -1

	# ==================================================
	# Remove
	# ==================================================

	if remove_button == null:

		push_error(
			"MutagenManagementUI: RemoveButton is missing."
		)

		return

	remove_button.slot_type = "remove"
	remove_button.slot_index = -1

	# ==================================================
	# Reward
	# ==================================================

	if reward_button == null:

		push_error(
			"MutagenManagementUI: RewardButton is missing."
		)

		return

	reward_button.slot_type = "reward"
	reward_button.slot_index = -1


# ==================================================
# Open
# ==================================================

func open(
	pending_reward: MutagenResource = null
) -> void:

	_load_current_build()

	temp_reward = pending_reward

	had_reward = (
		pending_reward != null
	)

	_refresh_ui()

	show()


# ==================================================
# Load Current Build
# ==================================================

func _load_current_build() -> void:

	temp_equipped.clear()

	temp_reserve = null

	temp_remove = null

	if run_mutagen_manager == null:

		push_error(
			"MutagenManagementUI: RunMutagenManager is missing."
		)

		return

	var equipped: Array[MutagenResource] = (
		run_mutagen_manager.get_equipped_mutagens()
	)

	for mutagen in equipped:

		temp_equipped.append(
			mutagen
		)

	# Always maintain six equipped positions.
	while temp_equipped.size() < EQUIPPED_SLOT_COUNT:

		temp_equipped.append(
			null
		)

	# Safety check.
	while temp_equipped.size() > EQUIPPED_SLOT_COUNT:

		temp_equipped.pop_back()

	temp_reserve = (
		run_mutagen_manager.reserve_mutagen
	)


# ==================================================
# Refresh UI
# ==================================================

func _refresh_ui() -> void:

	if slot_buttons.size() != EQUIPPED_SLOT_COUNT:

		return

	# ==================================================
	# Equipped
	# ==================================================

	for i in range(EQUIPPED_SLOT_COUNT):

		slot_buttons[i].set_mutagen(
			temp_equipped[i]
		)

	# ==================================================
	# Reserve
	# ==================================================

	reserve_button.set_mutagen(
		temp_reserve
	)

	# ==================================================
	# Remove
	# ==================================================

	remove_button.set_mutagen(
		temp_remove
	)

	# ==================================================
	# Reward
	# ==================================================

	reward_button.set_mutagen(
		temp_reward
	)


	# ==================================================
	# Reward Visibility
	# ==================================================

	if temp_reward != null:

		recovered_container.show()

	else:

		recovered_container.hide()

	# ==================================================
	# Instructions
	# ==================================================

	if temp_reward != null:

		instructions_label.text = (
			"Move Mutagens freely between Equipped, Reserve, "
			+ "and Remove.\n"
			+ "Place the recovered Mutagen in an empty slot "
			+ "or replace an equipped Mutagen.\n"
			+ "Leave cancels all changes. Confirm commits them."
		)

	else:

		instructions_label.text = (
			"Move Mutagens freely between Equipped, Reserve, "
			+ "and Remove.\n"
			+ "Reserve and Remove can each hold one Mutagen.\n"
			+ "Leave cancels all changes. Confirm commits them."
		)


# ==================================================
# Get Slot Mutagen
# ==================================================

func _get_slot_mutagen(
	slot_type: String,
	slot_index: int
) -> MutagenResource:

	match slot_type:

		"equipped":

			if (
				slot_index >= 0
				and
				slot_index < temp_equipped.size()
			):

				return temp_equipped[
					slot_index
				]

		"reserve":

			return temp_reserve

		"remove":

			return temp_remove

		"reward":

			return temp_reward

	return null


# ==================================================
# Validate Drop
# ==================================================

func _can_drop_mutagen(
	data
) -> bool:

	if not data is Dictionary:

		return false

	if not data.has(
		"mutagen"
	):

		return false

	var mutagen = data[
		"mutagen"
	]

	return mutagen != null


# ==================================================
# Handle Drop
# ==================================================

func handle_mutagen_drop(
	data: Dictionary,
	destination_type: String,
	destination_index: int
) -> void:

	if not _can_drop_mutagen(
		data
	):

		return

	var source_type: String = (
		data.get(
			"source_type",
			""
		)
	)

	var source_index: int = (
		data.get(
			"source_index",
			-1
		)
	)

	var mutagen: MutagenResource = (
		data.get(
			"mutagen",
			null
		)
	)

	if mutagen == null:

		return

	# --------------------------------------------------
	# Don't drop onto itself.
	# --------------------------------------------------

	if (
		source_type == destination_type
		and
		source_index == destination_index
	):

		return

	# --------------------------------------------------
	# Reward special handling.
	# --------------------------------------------------

	if source_type == "reward":

		_handle_reward_drop(
			destination_type,
			destination_index
		)

		_refresh_ui()

		return

	# --------------------------------------------------
	# Normal Mutagen movement.
	# --------------------------------------------------

	_handle_normal_drop(
		source_type,
		source_index,
		destination_type,
		destination_index
	)

	_refresh_ui()


# ==================================================
# Reward Drop
# ==================================================

func _handle_reward_drop(
	destination_type: String,
	destination_index: int
) -> void:

	if temp_reward == null:

		return

	# ==================================================
	# Reward → Equipped
	# ==================================================

	if destination_type == "equipped":

		if (
			destination_index < 0
			or
			destination_index >= EQUIPPED_SLOT_COUNT
		):

			return

		var old_mutagen: MutagenResource = (
			temp_equipped[
				destination_index
			]
		)

		# --------------------------------------------------
		# Empty slot
		# --------------------------------------------------

		if old_mutagen == null:

			temp_equipped[
				destination_index
			] = temp_reward

			temp_reward = null

			print(
				"Reward placed in equipped slot:",
				destination_index
			)

			return

		if temp_remove != null:

			print(
				"Cannot replace equipped Mutagen."
			)

			print(
				"Remove slot is already occupied."
			)

			return

		temp_remove = old_mutagen

		temp_equipped[
			destination_index
		] = temp_reward

		temp_reward = null

		print(
			"Reward replaced:",
			old_mutagen.mutagen_name,
			"with",
			temp_equipped[
				destination_index
			].mutagen_name
		)

		return

	# ==================================================
	# Reward → Reserve
	# ==================================================

	if destination_type == "reserve":

		if temp_reserve != null:

			print(
				"Cannot place reward in occupied Reserve."
			)

			return

		temp_reserve = temp_reward

		temp_reward = null

		print(
			"Reward placed in Reserve."
		)

		return

	# ==================================================
	# Reward → Remove
	# ==================================================

	print(
		"Reward cannot be placed in Remove."
	)

# ==================================================
# Normal Mutagen Movement
# ==================================================

func _handle_normal_drop(
	source_type: String,
	source_index: int,
	destination_type: String,
	destination_index: int
) -> void:

	var source_mutagen: MutagenResource = (
		_get_slot_mutagen(
			source_type,
			source_index
		)
	)

	if source_mutagen == null:

		return

	# ==================================================
	# Equipped → Equipped
	# ==================================================

	if (
		source_type == "equipped"
		and
		destination_type == "equipped"
	):

		if (
			destination_index < 0
			or
			destination_index >= EQUIPPED_SLOT_COUNT
		):

			return

		var destination_mutagen: MutagenResource = (
			temp_equipped[
				destination_index
			]
		)

		temp_equipped[
			destination_index
		] = source_mutagen

		temp_equipped[
			source_index
		] = destination_mutagen

		return

	# ==================================================
	# Equipped → Reserve
	# ==================================================

	if (
		source_type == "equipped"
		and
		destination_type == "reserve"
	):

		if temp_reserve == null:

			temp_reserve = source_mutagen

			temp_equipped[
				source_index
			] = null

			return

		var old_reserve: MutagenResource = (
			temp_reserve
		)

		temp_reserve = source_mutagen

		temp_equipped[
			source_index
		] = old_reserve

		return

	# ==================================================
	# Reserve → Equipped
	# ==================================================

	if (
		source_type == "reserve"
		and
		destination_type == "equipped"
	):

		if (
			destination_index < 0
			or
			destination_index >= EQUIPPED_SLOT_COUNT
		):

			return

		var old_equipped: MutagenResource = (
			temp_equipped[
				destination_index
			]
		)

		temp_equipped[
			destination_index
		] = source_mutagen

		temp_reserve = old_equipped

		return

	# ==================================================
	# Equipped → Remove
	# ==================================================

	if (
		source_type == "equipped"
		and
		destination_type == "remove"
	):

		if temp_remove != null:

			print(
				"Remove slot already occupied."
			)

			return

		temp_remove = source_mutagen

		temp_equipped[
			source_index
		] = null

		return

	# ==================================================
	# Reserve → Remove
	# ==================================================

	if (
		source_type == "reserve"
		and
		destination_type == "remove"
	):

		if temp_remove != null:

			print(
				"Remove slot already occupied."
			)

			return

		temp_remove = source_mutagen

		temp_reserve = null

		return

	# ==================================================
	# Remove → Equipped
	# ==================================================

	if (
		source_type == "remove"
		and
		destination_type == "equipped"
	):

		if (
			destination_index < 0
			or
			destination_index >= EQUIPPED_SLOT_COUNT
		):

			return

		var old_equipped: MutagenResource = (
			temp_equipped[
				destination_index
			]
		)

		temp_equipped[
			destination_index
		] = source_mutagen

		temp_remove = old_equipped

		return

	# ==================================================
	# Remove → Reserve
	# ==================================================

	if (
		source_type == "remove"
		and
		destination_type == "reserve"
	):

		if temp_reserve == null:

			temp_reserve = source_mutagen

			temp_remove = null

			return

		var old_reserve: MutagenResource = (
			temp_reserve
		)

		temp_reserve = source_mutagen

		temp_remove = old_reserve

		return

	# ==================================================
	# Invalid
	# ==================================================

	print(
		"Invalid Mutagen drop:",
		source_type,
		"->",
		destination_type
	)


# ==================================================
# Confirm
# ==================================================

func _on_confirm_pressed() -> void:

	var final_equipped: Array[MutagenResource] = []

	# ==================================================
	# Build Final Equipped List
	# ==================================================

	for mutagen in temp_equipped:

		if mutagen != null:

			final_equipped.append(
				mutagen
			)

	if final_equipped.size() > EQUIPPED_SLOT_COUNT:

		push_error(
			"MutagenManagementUI: Too many equipped Mutagens."
		)

		return

	# ==================================================
	# Reward Status
	# ==================================================

	var accepted_reward: bool = false

	if had_reward:

		# Reward was accepted if it is no longer sitting
		# in the Reward slot.
		accepted_reward = (
			temp_reward == null
		)

	# ==================================================
	# Debug
	# ==================================================

	print(
		"================================"
	)

	print(
		"MUTAGEN MANAGEMENT CONFIRMED"
	)

	print(
		"Equipped count:",
		final_equipped.size()
	)

	print(
		"Reserve:",
		temp_reserve
	)

	print(
		"Remove:",
		temp_remove
	)

	print(
		"Reward accepted:",
		accepted_reward
	)

	print(
		"================================"
	)

	# ==================================================
	# Commit Request
	# ==================================================

	management_confirmed.emit(
		final_equipped,
		temp_reserve,
		accepted_reward
	)

	# ==================================================
	# Close
	# ==================================================

	_reset_temp_state()

	hide()


# ==================================================
# Leave
# ==================================================

func _on_leave_pressed() -> void:

	print(
		"Mutagen management left without confirmation."
	)

	# Discard temporary changes.
	_reset_temp_state()

	hide()

	management_finished.emit()

# ==================================================
# Reset Temporary State
# ==================================================

func _reset_temp_state() -> void:

	temp_equipped.clear()

	for i in range(EQUIPPED_SLOT_COUNT):

		temp_equipped.append(
			null
		)

	temp_reserve = null

	temp_remove = null

	temp_reward = null

	had_reward = false
