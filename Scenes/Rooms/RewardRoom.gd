extends Control
class_name RewardRoom


signal reward_finished(reward)

@onready var reward_container = $CenterContainer/VBoxContainer/RewardContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton

const REWARD_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")

var selected_reward = null

func _ready():
	continue_button.pressed.connect(
		_on_continue_pressed
	)
	
func open(rewards):
	show()
	
	selected_reward = null
	
	create_rewards(rewards.gene_choices)
	
	continue_button.disabled = false

func close():
	hide()

func create_rewards(rewards):
	
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
				select_reward(reward)
		)

		reward_container.add_child(button)
	
		
func select_reward(reward):
	selected_reward = reward
	
	print("Selected reward:", reward.gene_name)
	
	continue_button.disabled = false
	
	
func _on_continue_pressed():
	if selected_reward == null:
		print("Skipped reward")
	else:
		print("Reward chosen:", selected_reward.gene_name)
	
	reward_finished.emit(selected_reward)
	 
