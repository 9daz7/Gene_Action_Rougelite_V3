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


# ==================================================
# Public Functions
# ==================================================


func open(rewards):

	show()

	selected_reward = null

	for child in reward_container.get_children():
		child.queue_free()

	if rewards!= null:
		
		_create_gene_buttons(
			rewards.gene_choices
		)

		_create_mutagen_buttons(
			rewards.mutagen_choices
		)

	continue_button.disabled = true


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
	rewards: Array[GeneResource]
) -> void:

	print("================================")
	print("CREATING GENE REWARDS")
	print("================================")

	for reward in rewards:

		if reward == null:
			continue

		var button_scene = load(
			"res://Scenes/UI/RewardButton.tscn"
		)

		if button_scene == null:

			push_error(
				"RewardRoom: Failed to load RewardButton.tscn"
			)

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
				_select_reward(
					reward
				)
		)

		reward_container.add_child(
			button
		)

	print(
		"Gene rewards:",
		rewards.size()
	)


func _create_mutagen_buttons(
	rewards: Array[MutagenResource]
) -> void:

	print("================================")
	print("CREATING MUTAGEN REWARDS")
	print("================================")

	for reward in rewards:

		if reward == null:
			continue

		var button_scene = load(
			"res://Scenes/UI/RewardButton.tscn"
		)

		if button_scene == null:

			push_error(
				"RewardRoom: Failed to load RewardButton.tscn"
			)

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
				_select_reward(
					reward
				)
		)

		reward_container.add_child(
			button
		)

	print(
		"Mutagen rewards:",
		rewards.size()
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

	for button in reward_container.get_children():

		button.disabled = true

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
