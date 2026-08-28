extends Control
class_name RewardRoom


# ==================================================
# Signals
# ==================================================

signal reward_finished(reward)


# ==================================================
# Constants
# ==================================================
#const REWARD_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")


# ==================================================
# Onready Variables
# ==================================================

@onready var reward_container = $CenterContainer/VBoxContainer/RewardContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton
@onready var skip_button = $CenterContainer/VBoxContainer/SkipButton

# ==================================================
# Member Variables
# ==================================================

var selected_reward = null


# ==================================================
# Initialization
# ==================================================


func _ready():
	continue_button.pressed.connect(
		_on_continue_pressed
	)

	skip_button.pressed.connect(
		_on_skip_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(rewards):

	show()

	selected_reward = null

	for child in reward_container.get_children():

		child.queue_free()

	var columns := HBoxContainer.new()

	columns.name = "RewardColumns"

	columns.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	reward_container.add_child(
		columns
	)

	# ==================================================
	# Gene Column
	# ==================================================

	var gene_column := VBoxContainer.new()

	gene_column.name = "GeneColumn"

	gene_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	columns.add_child(
		gene_column
	)

	var gene_title := Label.new()

	gene_title.text = "GENES"

	gene_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	gene_column.add_child(
		gene_title
	)

	# ==================================================
	# Mutagen Column
	# ==================================================

	var mutagen_column := VBoxContainer.new()

	mutagen_column.name = "MutagenColumn"

	mutagen_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	columns.add_child(
		mutagen_column
	)

	var mutagen_title := Label.new()

	mutagen_title.text = "MUTAGENS"

	mutagen_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	mutagen_column.add_child(
		mutagen_title
	)

	# ==================================================
	# Populate
	# ==================================================

	if rewards != null:

		_create_gene_buttons(
			rewards.gene_choices,
			gene_column
		)

		_create_mutagen_buttons(
			rewards.mutagen_choices,
			mutagen_column
		)

	continue_button.disabled = true

	#show()
#
	#selected_reward = null
#
	#for child in reward_container.get_children():
		#child.queue_free()
#
	#if rewards!= null:
		#
		#_create_gene_buttons(
			#rewards.gene_choices
		#)
#
		#_create_mutagen_buttons(
			#rewards.mutagen_choices
		#)
#
	#continue_button.disabled = true


func close():
	hide()


# ==================================================
# Private Functions
# ==================================================


#func _create_reward_buttons(rewards):
#
	#print("================================")
	#print("CREATING REWARD BUTTONS")
	#print("================================")
#
	#print("Reward count:", rewards.size())
	#print("Rewards received:", rewards)
	#print("Reward type:", typeof(rewards))
#
	#for reward in rewards:
#
		#print("Creating reward:", reward)
#
		#if not reward is GeneResource:
#
			#push_error(
				#"RewardRoom: Invalid reward type: "
				#+ str(reward)
			#)
#
			#continue
#
		#var button_scene = load(
			#"res://Scenes/UI/RewardButton.tscn"
		#)
#
		#if button_scene == null:
#
			#push_error(
				#"RewardRoom: Failed to load RewardButton.tscn"
			#)
#
			#return
#
		#var button = button_scene.instantiate()
#
		#if button == null:
#
			#push_error(
				#"RewardRoom: Failed to instantiate RewardButton"
			#)
#
			#return
#
		#button.text = reward.gene_name
#
		#button.custom_minimum_size = Vector2(
			#300,
			#60
		#)
#
		#button.pressed.connect(
			#func():
				#_select_reward(reward)
		#)
#
		#reward_container.add_child(button)
#
		#print(
			#"Reward button added:",
			#reward.gene_name
		#)
#
	#print(
		#"Final button count:",
		#reward_container.get_child_count()
	#)
#
	#print("================================")


func _create_gene_buttons(
	rewards: Array[GeneResource],
	parent: Container
) -> void:

	for reward in rewards:

		if reward == null:
			continue

		var button_scene = load(
			"res://Scenes/UI/RewardButton.tscn"
		)

		if button_scene == null:
			return

		var button = button_scene.instantiate()

		if button == null:
			return

		button.text = reward.gene_name

		button.custom_minimum_size = Vector2(
			300,
			60
		)

		button.pressed.connect(
			func():
				_select_reward(reward)
		)

		parent.add_child(
			button
		)


func _create_mutagen_buttons(
	rewards: Array[MutagenResource],
	parent: Container
) -> void:

	for reward in rewards:

		if reward == null:
			continue

		var button_scene = load(
			"res://Scenes/UI/RewardButton.tscn"
		)

		if button_scene == null:
			return

		var button = button_scene.instantiate()

		if button == null:
			return

		button.text = reward.mutagen_name

		button.custom_minimum_size = Vector2(
			300,
			60
		)

		button.pressed.connect(
			func():
				_select_reward(reward)
		)

		parent.add_child(
			button
		)


func _select_reward(
	reward
) -> void:

	if selected_reward != null:
		return
		
	selected_reward = reward
	
	print(
		"Selected reward:",
		_get_reward_name(reward)
	)

	# Disable every reward button
	var columns := reward_container.get_node_or_null(
		"RewardColumns"
	)

	if columns != null:

		for column in columns.get_children():

			for child in column.get_children():

				if child is Button:

					child.disabled = true

	continue_button.disabled = false
func _get_reward_name(
	reward
) -> String:

	if reward is GeneResource:

		return reward.gene_name

	if reward is MutagenResource:

		return reward.mutagen_name

	return "Unknown Reward"


func _on_continue_pressed() -> void:

	if selected_reward == null:

		print(
			"Skipped reward"
		)

	else:

		print(
			"Reward chosen:",
			_get_reward_name(
				selected_reward
			)
		)

	reward_finished.emit(
		selected_reward
	)


func _on_skip_pressed() -> void:

	print(
		"Player skipped reward."
	)

	selected_reward = null

	reward_finished.emit(
		null
	)
