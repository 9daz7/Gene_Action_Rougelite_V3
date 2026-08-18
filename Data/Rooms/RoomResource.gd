extends Resource
class_name RoomResource

# ==================================================
# Room Types
# ==================================================


enum RoomType {
	BATTLE,
	ELITE,
	REWARD,
	SHOP,
	EVENT,
	BOSS 
}


# ==================================================
# Room Information
# ==================================================


@export var room_type: RoomType = RoomType.BATTLE

@export var room_name: String = "Battle"

@export_multiline var description: String = ""


# ==================================================
# Room State
# ==================================================


var completed: bool = false
