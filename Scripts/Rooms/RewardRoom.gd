extends Control
class_name RewardRoom


# ==================================================
# Signals
# ==================================================

signal reward_finished(reward)


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
	
	if rewards!= null:
		_create_reward_buttons(rewards.gene_choices)
	
	continue_button.disabled = false


func close():
	hide()


# ==================================================
# Private Functions
# ==================================================


func _create_reward_buttons(rewards):
	
	print("Reward count:", rewards.size())
	print("Rewards received:", rewards)
	print("Reward type:", typeof(rewards))
	
	for child in reward_container.get_children():
		child.queue_free()
		
	for reward in rewards:
		var button = REWARD_BUTTON.instantiate()
		
		button.text = reward.gene_name
		
		button.custom_minimum_size = Vector2(
			300,
			60
		)

		button.pressed.connect(
			func():
				_select_reward(reward)
		)

		reward_container.add_child(button)


func _select_reward(reward):
	
	if selected_reward != null:
		return
		
	selected_reward = reward
	
	print("Selected reward:", reward.gene_name)
	
	for button in reward_container.get_children():
		button.disabled = true
	
	continue_button.disabled = false
	
	
func _on_continue_pressed():
	if selected_reward == null:
		print("Skipped reward")
	else:
		print("Reward chosen:", selected_reward.gene_name)
	
	reward_finished.emit(selected_reward)
	 
