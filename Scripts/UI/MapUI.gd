extends Control
class_name MapUI


signal room_entered(room)


@onready var room_container = $RoomContainer
# @onready var connections = $Connections


const ROOM_BUTTON = preload("res://Scenes/UI/RoomButton.tscn")


var map: Array[RoomData] = []

var map_scale := 0.8


func display_map(generated_map: Array):
	map = generated_map

	clear_map()

	room_container.scale = Vector2.ONE * map_scale

	for room in map:
		create_room_button(room)

	queue_redraw()


func clear_map():
	for child in room_container.get_children():
		child.queue_free()


func create_room_button(room: RoomData):
	var button = ROOM_BUTTON.instantiate()

	room_container.add_child(button)

	button.setup(room)

	button.room_selected.connect(_on_room_selected)


func _draw():
	for room in map:
		for connection in room.connections:
			draw_line(
				room.position + Vector2(40, 25),
				connection.position + Vector2(40, 25),
				Color.WHITE,
				3
			)


func _on_room_selected(room):
	print("ENTERING ROOM:", room.room_type)

	room_entered.emit(room)

	match room.room_type:
		RoomData.RoomType.ENEMY:
			print("Starting enemy battle")

		RoomData.RoomType.ELITE:
			print("Starting elite battle")

		RoomData.RoomType.MERCHANT_TRAP:
			print("Merchant was a trap!")
			print("Starting trap battle")

		RoomData.RoomType.TREASURE:
			print("Opening treasure")

		RoomData.RoomType.REST:
			print("Rest room")

		RoomData.RoomType.MERCHANT:
			print("Merchant")

		RoomData.RoomType.LAB:
			print("Laboratory")

		RoomData.RoomType.BOSS:
			print("BOSS FIGHT")
