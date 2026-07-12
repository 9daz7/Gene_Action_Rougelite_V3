extends Resource
class_name RoomData


enum RoomType {
	START,
	ENEMY,
	GROUP_ENEMY,
	ELITE,
	REST,
	TREASURE,
	MERCHANT,
	LAB,
	UNKNOWN,
	AMBUSH,
	MERCHANT_TRAP,
	BOSS
}


var room_id := 0

var row := 0
var lane := 0

var position := Vector2.ZERO

var room_type : RoomType

var connections : Array[RoomData] = []

var visited := false
var completed := false
var unlocked := false
