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
	BOSS,
	REST,
	TREASURE
}


# ==================================================
# Room Information
# ==================================================

@export var room_type: RoomType = RoomType.BATTLE
@export var room_name: String = "Battle"
@export_multiline var description: String = ""


# ==================================================
# Room Scene
# ==================================================

@export var room_scene: PackedScene


# ==================================================
# Room State
# ==================================================

@export var completed: bool = false
