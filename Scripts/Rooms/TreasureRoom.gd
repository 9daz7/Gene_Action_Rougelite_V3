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
	
	if selected_reward != null:
		return
	
	selected_reward = reward
	
	print("Selected reward:", reward)
	
	for button in reward_container.get_children():
		button.disabled = true

	
	continue_button.disabled = false
	

func create_test_rewards():

	for child in reward_container.get_children():
		child.queue_free()

	var rewards = [
		{
			"text": "50 Gold",
			"gold": 50,
		},
		{
			"text": "Random Gene",
			"gold": 0
		},
		{
			"text": "Heal 25 HP",
			"gold": 0
		}
	]

	for reward in rewards:

		var button = REWARD_BUTTON.instantiate()
		
		reward_container.add_child(button)

		button.text = reward.text

		button.pressed.connect(
			func():
				choose_reward(reward)
		)

		
		
# -------------------------------------------------------------------
# Continue
# -------------------------------------------------------------------

func _on_continue_pressed():

	print("Treasure room completed")
	
	if selected_reward.has("gold"):
		run_manager.save_manager.gold += selected_reward.gold
			
	print("Gold:", run_manager.save_manager.gold)
	
	run_manager.save_manager.save_game(run_manager)

	treasure_finished.emit(selected_reward)

	queue_free()
	
