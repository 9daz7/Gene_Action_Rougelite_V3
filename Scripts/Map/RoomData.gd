extends Resource
class_name RoomData

enum RoomType{
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

var row:int
var lane:int
var position:Vector2

var room_id:int

var room_type:RoomType

var connections:Array[RoomData] = []
