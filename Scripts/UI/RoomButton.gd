extends Button
class_name RoomButton


signal room_selected(room)


var room_data: RoomData


func setup(room: RoomData):
	room_data = room

	text = get_room_text()
	
	if room.completed:
		text += "\n✓"
		
	position = room.position
	custom_minimum_size = Vector2(80, 40)
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)


func get_room_text():
	match room_data.room_type:
		
		RoomData.RoomType.START:
			return "START"
		
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

		RoomData.RoomType.ABANDONED_LAB:
			return "LAB"

		RoomData.RoomType.BOSS:
			return "BOSS"

		_:
			return "MYSTERY"


func _on_pressed():
	
	if disabled:
		return
		
	print("Selected room ID:", room_data.room_id)
	

	room_selected.emit(room_data)
