extends Control
class_name TreasureRoom


# ==================================================
# Signals
# ==================================================

signal treasure_finished(reward)


# ==================================================
# Constants
# ==================================================

const REWARD_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")


# ==================================================
# Onready Variables
# ==================================================

@onready var reward_container = $CenterContainer/VBoxContainer/RewardContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton
@onready var run_manager = $"../Managers/RunManager"


# ==================================================
# Member Variables
# ==================================================

var selected_reward = null

# ==================================================
# Initialization
# ==================================================


func _ready():

	continue_button.pressed.connect(_on_continue_pressed)


# ==================================================
# Public Functions
# ==================================================


func open(manager:RunManager):

	run_manager = manager
	show()

	selected_reward = null

	continue_button.disabled = true

	_create_test_rewards()


func close():

	hide()


# ==================================================
# Private Functions
# ==================================================


func _create_test_rewards():

	# eventually replace with generated treasure rewards.

	for child in reward_container.get_children():
		child.queue_free()

	var rewards = [
		{
			"text": "50 Gold",
			"gold": 50,
		},
		{
			"text": "Random Gene",
			"gold": 0,
		},
		{
			"text": "Heal 25 HP",
			"gold": 0,
		},
	]

	for reward in rewards:
		var button = REWARD_BUTTON.instantiate()
		button.text = reward.text
		button.pressed.connect(
			func():
				_select_reward(reward)
		)

		reward_container.add_child(button)


func _select_reward(reward):

	if selected_reward != null:
		return

	selected_reward = reward

	print("Selected reward:", reward)

	for button in reward_container.get_children():
		button.disabled = true

	continue_button.disabled = false


func _on_continue_pressed():

	print("Treasure room completed")

	_apply_reward()

	run_manager.save_manager.save_game(run_manager)

	treasure_finished.emit(selected_reward)

	queue_free()


# ==================================================
# Helpers
# ==================================================


func _apply_reward():

	if selected_reward == null:
		return

	if selected_reward.has("gold"):
		
		run_manager.gold += selected_reward.gold

	print(
		"Gold:",
		run_manager.gold
	)
