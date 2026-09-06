extends Resource
class_name RoomData


# ==================================================
# Enums
# ==================================================


enum RoomType {
	START,
	ENEMY,
	GROUP_ENEMY,
	ELITE,
	REST,
	TREASURE,
	MERCHANT,
	ABANDONED_LAB,
	MYSTERY_ROOM,
	AMBUSH,
	MERCHANT_TRAP,
	BOSS,
	LAB
}


# ==================================================
# Member Variables
# ==================================================


# Map identification
var room_id := 0

# Map position data
var row := 0
var lane := 0
var position := Vector2.ZERO

# Room properties
var room_type : RoomType

var lab_data: LabResource = null

# Connections
var connections : Array[RoomData] = []

# State tracking
var visited := false
var completed := false
var available := false
