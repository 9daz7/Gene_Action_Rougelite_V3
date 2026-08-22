extends Control
class_name TreasureRoom_UI


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


# ==================================================
# Member Variables
# ==================================================

var run_manager: RunManager = null
var selected_reward = null

# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	if not continue_button.pressed.is_connected(
		_on_continue_pressed
	):

		continue_button.pressed.connect(
			_on_continue_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(
	manager: RunManager
) -> void:

	if manager == null:

		push_error(
			"TreasureRoom_UI: RunManager is missing."
		)

		return

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


func _create_test_rewards() -> void:

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


func _select_reward(reward) -> void:

	if selected_reward != null:
		return

	selected_reward = reward

	print("Selected reward:", reward)

	for button in reward_container.get_children():
		button.disabled = true

	continue_button.disabled = false


func _on_continue_pressed() -> void:

	if selected_reward == null:

		return

	print(
		"Treasure room completed"
	)

	_apply_reward()

	treasure_finished.emit(
		selected_reward
	)


# ==================================================
# Helpers
# ==================================================


func _apply_reward() -> void:

	if selected_reward == null:
		return

	if run_manager == null:

		push_error(
			"TreasureRoom_UI: RunManager is missing."
		)

		return

	# --------------------------------------------------
	# Run Gold
	# --------------------------------------------------

	var gold_amount: int = int(
		selected_reward.get("gold", 0)
	)

	if gold_amount > 0:

		run_manager.add_gold(
			gold_amount
		)

		print(
			"Treasure gold gained:",
			gold_amount
		)

		print(
			"Run gold:",
			run_manager.gold
		)
