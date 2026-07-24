extends Node
class_name RoomManager


# ==================================================
# Onready Variables
# ==================================================


@onready var battle_manager = $"../BattleManager"
@onready var run_manager = $"../RunManager"
@onready var save_manager = $"../SaveManager"


# ==================================================
# Constants
# ==================================================


const TREASURE_SCENE = preload("res://Scenes/Rooms/TreasureRoom.tscn")
const MERCHANT_SCENE = preload("res://Scenes/Rooms/MerchantRoom.tscn")
const REST_SCENE = preload("res://Scenes/Rooms/RestRoom.tscn")
const ABANDONED_LAB_SCENE = preload("res://Scenes/Rooms/AbandonedLab.tscn")
const MYSTERY_SCENE = preload("res://Scenes/Rooms/MysteryRoom.tscn")

const REWARD_SCENE = preload("res://Scenes/Rooms/RewardRoom.tscn")


# ==================================================
# Member Variables
# ==================================================


var reward_room: RewardRoom = null

var treasure_room = null
var merchant_room = null
var rest_room = null
var abandoned_lab = null
var mystery_room = null


# ==================================================
# Public Functions
# ==================================================


func enter_room(room:RoomData):
	
	print("ROOM MANAGER ENTERED:", room.room_type)
	
	match room.room_type:
		
		RoomData.RoomType.ENEMY:
			start_enemy(room)
			
		RoomData.RoomType.ELITE:
			start_elite(room)
			
		RoomData.RoomType.GROUP_ENEMY:
			start_group_enemy(room)
			
		RoomData.RoomType.BOSS:
			start_boss(room)
			
		RoomData.RoomType.TREASURE:
			open_treasure(room)
			
		RoomData.RoomType.MERCHANT:
			open_shop(room)
			
		RoomData.RoomType.REST:
			open_rest(room)
			
		RoomData.RoomType.ABANDONED_LAB:
			open_lab(room)
			
		RoomData.RoomType.MYSTERY_ROOM:
			open_mystery(room)
			
		_:
			print("Unknown room")


func open_reward(rewards):

	reward_room = REWARD_SCENE.instantiate()

	get_tree().current_scene.add_child(reward_room)

	reward_room.reward_finished.connect(
		_on_reward_finished
	)

	reward_room.open(rewards)


# ==================================================
# Battle Rooms
# ==================================================


func start_enemy(room):
	print("Starting normal battle")
	battle_manager.start_battle(RoomData.RoomType.ENEMY)

func start_group_enemy(room):
	print("Starting group battle")
	battle_manager.start_group_battle()

func start_elite(room):
	print("Starting elite battle")
	battle_manager.start_battle(RoomData.RoomType.ELITE)


func start_boss(room):
	print("Starting boss")
	battle_manager.start_battle(RoomData.RoomType.BOSS)


# ==================================================
# Special Rooms
# ==================================================


func open_shop(room):

	print("Opening merchant")

	merchant_room = MERCHANT_SCENE.instantiate()

	get_tree().current_scene.add_child(merchant_room)

	merchant_room.merchant_finished.connect(
		_on_merchant_finished
	)

	merchant_room.open()


func open_treasure(room):
	
	print("Opening treasure")

	treasure_room = TREASURE_SCENE.instantiate()

	get_tree().current_scene.add_child(treasure_room)

	treasure_room.treasure_finished.connect(_on_treasure_finished)

	treasure_room.open(run_manager)


func open_rest(room):

	print("Opening rest room")

	rest_room = REST_SCENE.instantiate()

	get_tree().current_scene.add_child(rest_room)

	rest_room.rest_finished.connect(_on_rest_finished)

	rest_room.open(run_manager)


func open_lab(room):

	print("Opening abandoned lab")

	if room.lab_data == null:
		print("ERROR: Lab room has no LabResource")
		return

	abandoned_lab = ABANDONED_LAB_SCENE.instantiate()
	get_tree().current_scene.add_child(abandoned_lab)

	abandoned_lab.lab_finished.connect(
		_on_lab_finished
	)

	abandoned_lab.open(
		room.lab_data
	)


func open_mystery(room):
	print("Opening a mystery room")

	mystery_room = MYSTERY_SCENE.instantiate()

	get_tree().current_scene.add_child(mystery_room)

	mystery_room.mystery_finished.connect(
		_on_mystery_finished
	)


# ==================================================
# Reward Handling
# ==================================================


func _on_reward_finished(reward):

	if reward:
		print("Chosen:", reward)
	else:
		print("Skipped reward")

	if is_instance_valid(reward_room):
		reward_room.queue_free()

	reward_room = null

	if reward:
		apply_reward(reward)

	get_tree().current_scene.return_to_map()


func apply_reward(reward):

	if reward == null:
		print("No reward selected")
		return

	print(
		"Applying reward:",
		reward
	)

	if reward is GeneResource:
		run_manager.unlock_gene(reward)
		save_manager.save_game(run_manager)

	else:
		print("Unknown reward type")

	# Temporary
	# Actual reward logic will go here later


# ==================================================
# Room Completion
# ==================================================


func _on_treasure_finished(reward):

	print("Treasure complete", reward)

	treasure_room = null

	get_tree().current_scene.return_to_map()


func _on_merchant_finished():

	print("Merchant complete")

	if is_instance_valid(merchant_room):
		merchant_room.close()
		merchant_room.queue_free()

	merchant_room = null

	get_tree().current_scene.return_to_map()


func _on_rest_finished():

	print("Rest complete")

	rest_room = null

	get_tree().current_scene.return_to_map()


func _on_lab_finished():

	print("Lab complete")

	if is_instance_valid(abandoned_lab):
		abandoned_lab.close()
		abandoned_lab.queue_free()

	abandoned_lab = null

	get_tree().current_scene.return_to_map()


func _on_mystery_finished():

	if is_instance_valid(mystery_room):
		mystery_room.queue_free()

	mystery_room = null

	print("Mystery complete")

	get_tree().current_scene.return_to_map()
