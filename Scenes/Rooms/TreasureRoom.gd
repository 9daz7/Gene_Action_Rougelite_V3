extends Control
class_name TreasureRoom


signal treasure_finished(reward)


@onready var reward_container = $CenterContainer/VBoxContainer/RewardContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton
@onready var run_manager = $"../Managers/RunManager"


const REWARD_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")

var selected_reward = null

# -------------------------------------------------------------------
# Setup
# -------------------------------------------------------------------


func _ready():

	continue_button.pressed.connect(_on_continue_pressed)
	
	
func open():
	
	show()
	
	selected_reward = null
	
	continue_button.disabled = true
	
	create_test_rewards()
	
# -------------------------------------------------------------------
# Reward Selection
# -------------------------------------------------------------------

func choose_reward(reward):
	
	selected_reward = reward
	
	print("Selected reward:", reward)
	
	continue_button.disabled = false
	

func create_test_rewards():

	for child in reward_container.get_children():
		child.queue_free()

	var rewards = [
		"100 Gold",
		"Random Gene",
		"Heal 25 HP"
	]

	for reward in rewards:

		var button = REWARD_BUTTON.instantiate()
		
		reward_container.add_child(button)

		button.text = reward

		button.pressed.connect(
			func():
				choose_reward(reward)
		)

		
		
# -------------------------------------------------------------------
# Continue
# -------------------------------------------------------------------

func _on_continue_pressed():

	print("Treasure room completed")
	
	run_manager.gold += selected_reward.gold

	treasure_finished.emit(selected_reward)

	queue_free()
	
