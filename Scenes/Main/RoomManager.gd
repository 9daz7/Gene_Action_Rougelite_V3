extends Node
class_name RoomManager


@onready var battle_manager = $"../BattleManager"
@onready var run_manager = $"../RunManager"
@onready var save_manager = $"../SaveManager"

const TREASURE_SCENE = preload("res://Scenes/Rooms/TreasureRoom.tscn")
const MERCHANT_SCENE = preload("res://Scenes/Rooms/MerchantRoom.tscn")

const REWARD_SCENE = preload("res://Scenes/Rooms/RewardRoom.tscn")

var reward_room = null

var treasure_room = null
var merchant_room = null


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
			
		RoomData.RoomType.LAB:
			open_lab(room)
			
		_:
			print("Unknown room")
			
			
# --------------------------------------------------
# Battles
# --------------------------------------------------

func start_enemy(room):
	print("Starting normal battle")
	battle_manager.start_battle()



func start_elite(room):
	print("Starting elite battle")
	battle_manager.start_elite_battle()



func start_group_enemy(room):
	print("Starting group battle")



func start_boss(room):
	print("Starting boss")
	battle_manager.start_boss_battle()


# --------------------------------------------------
# Special Rooms
# --------------------------------------------------


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
	
	treasure_room.open()


func open_rest(room):
	print("REST OPEN")


func open_lab(room):
	print("LAB OPEN")


func open_reward(rewards):
	reward_room = REWARD_SCENE.instantiate()

	get_tree().current_scene.add_child(
		reward_room
	)

	reward_room.reward_finished.connect(
		_on_reward_finished
	)

	reward_room.open(rewards.gene_choices)


func _on_reward_finished(reward):

	if reward == null:
		print("No reward selected")
	else:	
		print("Chosen:", reward.gene_name)

	if is_instance_valid(reward_room):
		reward_room.queue_free()

	reward_room = null

	apply_reward(reward)

	get_tree().current_scene.return_to_map()

func apply_reward(reward):
	
	if reward == null:
		print("No reward selected")
		return
		
	print("Applying reward:", reward.gene_name)

	if reward is GeneResource:
		run_manager.collect_gene(reward)
		save_manager.save_game(run_manager)
		
	# Temporary
	# Actual reward logic will go here later
	
	
func _on_treasure_finished(reward):

	print("Treasure complete", reward)

	treasure_room = null

	get_tree().current_scene.return_to_map()
	
	
func _on_merchant_finished():

	print("Merchant complete")

	if is_instance_valid(merchant_room):
		merchant_room.queue_free()

	merchant_room = null

	get_tree().current_scene.return_to_map()
	
	
