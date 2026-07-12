extends Node
class_name RoomManager


@onready var battle_manager = $"../BattleManager"

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



func open_shop(room):
	print("SHOP OPEN")


func open_treasure(room):
	print("TREASURE OPEN")


func open_rest(room):
	print("REST OPEN")


func open_lab(room):
	print("LAB OPEN")
