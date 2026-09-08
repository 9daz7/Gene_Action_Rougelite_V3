extends RoomWorld
class_name AbandonedLab


# ==================================================
# Scenes
# ==================================================

const LAB_UI_SCENE = preload(
	"res://Scenes/Rooms/AbandonedLab_UI.tscn"
)


# ==================================================
# Managers
# ==================================================

@onready var battle_manager: BattleManager = get_node(
	"../Managers/BattleManager"
)


# ==================================================
# Interaction
# ==================================================

@onready var lab_interactable: Interactable = $LabInteractable


# ==================================================
# State
# ==================================================

var lab_ui: AbandonedLab_UI = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:
	
	super._ready()

	if lab_interactable == null:

		push_error(
			"AbandonedLabWorld: LabInteractable not found."
		)

		return

	if not lab_interactable.interacted.is_connected(
		_on_lab_interacted
	):

		lab_interactable.interacted.connect(
			_on_lab_interacted
	)


# ==================================================
# Lab
# ==================================================


func _on_lab_interacted() -> void:

	if is_instance_valid(lab_ui):
		return

	var current_room: RoomResource = (
		room_manager.current_room
	)

	if current_room == null:

		push_error(
			"AbandonedLabWorld: No current RoomResource."
		)

		return

	# ==================================================
	# Lab Permanently Locked
	# ==================================================

	if current_room.lab_mutagen_editing_completed:

		print(
			"Lab already completed. Interaction blocked."
		)

		return

	print("================================")
	print("ABANDONED LAB ENTERED")
	print("================================")

	if room_player != null:

		room_player.set_controls_enabled(
			false
		)

	lab_ui = LAB_UI_SCENE.instantiate() as AbandonedLab_UI

	if lab_ui == null:

		push_error(
			"AbandonedLabWorld: Failed to instantiate lab UI."
		)

		if room_player != null:

			room_player.set_controls_enabled(
				true
			)

		return

	get_tree().current_scene.get_node("UI").add_child(
		lab_ui
	)

	if lab_ui is Control:

		lab_ui.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

	lab_ui.lab_finished.connect(
		_on_lab_finished
	)

	print(
		"Lab UI signal connected:",
		lab_ui.lab_finished.is_connected(
			_on_lab_finished
		)
	)

	#if current_room == null:
#
		#push_error(
			#"AbandonedLabWorld: No current RoomResource."
		#)
#
		#return

	if current_room.lab_data == null:

		push_error(
			"AbandonedLabWorld: Current room has no LabResource."
		)

		return

	lab_ui.open(
		current_room.lab_data,
		battle_manager
	)


# ==================================================
# Lab Complete
# ==================================================

func _on_lab_finished() -> void:

	print("================================")
	print("ABANDONED LAB FINISHED")
	print("================================")


	var current_room: RoomResource = (
		room_manager.current_room
	)

	if current_room == null:

		push_error(
			"AbandonedLabWorld: No current RoomResource."
		)

		return

	# ==================================================
	# Close Lab UI
	# ==================================================

	if is_instance_valid(lab_ui):

		lab_ui.close()
		lab_ui.queue_free()

		lab_ui = null

		print(
			"Lab UI closed and freed"
		)

	# ==================================================
	# Check Mutagen Editing State
	# ==================================================

	if current_room.lab_mutagen_editing_completed:

		print(
			"Lab editing completed."
		)

		print(
			"Completing Lab room."
		)

		room_manager.complete_room()

	else:

		print(
			"Lab editing NOT completed."
		)

		print(
			"Lab remains available for re-entry."
		)

	# ==================================================
	# Restore Player
	# ==================================================

	if room_player != null:

		room_player.set_controls_enabled(
			true
		)

	print(
		"ABANDONED LAB PLAYER CONTROLS RESTORED"
	)


func _exit_tree() -> void:

	print(
		"AbandonedLab exiting tree"
	)

	if is_instance_valid(lab_ui):

		lab_ui.close()

		lab_ui.queue_free()

		lab_ui = null

		print(
			"AbandonedLab UI cleaned up"
	)
