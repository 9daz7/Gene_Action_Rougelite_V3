extends Button
class_name RoomButton


signal room_selected(room)


var room_data: RoomData


func setup(room: RoomData):
	room_data = room

	text = get_room_text()
	position = room.position
	custom_minimum_size = Vector2(80, 40)

	pressed.connect(_on_pressed)


func get_room_text():
	match room_data.room_type:
		RoomData.RoomType.ENEMY:
			return "ENEMY"

		RoomData.RoomType.ELITE:
			return "ELITE"

		RoomData.RoomType.REST:
			return "REST"

		RoomData.RoomType.TREASURE:
			return "TREASURE"

		RoomData.RoomType.MERCHANT:
			return "SHOP"

		RoomData.RoomType.MERCHANT_TRAP:
			return "TRAP"

		RoomData.RoomType.LAB:
			return "LAB"

		RoomData.RoomType.BOSS:
			return "BOSS"

		_:
			return "?"


func _on_pressed():
	print("Selected room:", room_data.room_type)
	
	if disabled:
		return

	room_selected.emit(room_data)
