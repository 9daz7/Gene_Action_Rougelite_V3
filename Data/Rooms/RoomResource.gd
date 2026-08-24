extends Resource
class_name RoomResource


# ==================================================
# Room Types
# ==================================================

enum RoomType {
	START,
	BATTLE,
	ELITE,
	REWARD,
	SHOP,
	EVENT,
	BOSS,
	REST,
	TREASURE,
	LAB
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
# Room Layout
# ==================================================

@export_range(
	0,
	3,
	1
) var exit_count: int = 1


# ==================================================
# Lab Data
# ==================================================

@export var lab_data: LabResource


# ==================================================
# Room State
# ==================================================

@export var completed: bool = false
