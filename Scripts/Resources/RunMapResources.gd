extends Resource
class_name RunMapResource


# ==================================================
# Run Rooms
# ==================================================

@export var start_room: RoomResource = null

@export var rooms: Array[RoomResource] = []


# ==================================================
# Current Room
# ==================================================

var current_room: RoomResource = null
