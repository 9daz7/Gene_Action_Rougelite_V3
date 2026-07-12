extends Control
class_name MapUI


signal room_entered(room)


@onready var map_manager = $"../../Managers/MapManager"
@onready var room_container = $RoomContainer
@onready var connections = $Connections


const ROOM_BUTTON = preload("res://Scenes/UI/RoomButton.tscn")


var map: Array[RoomData] = []

var map_scale := 0.8


func display_map(generated_map: Array):
	map = generated_map

	clear_map()

	room_container.scale = Vector2.ONE * map_scale
	connections.scale = Vector2.ONE * map_scale

	for room in map:
		create_room_button(room)

	
	connections.set_map(map)


func clear_map():
	for child in room_container.get_children():
		child.queue_free()


func create_room_button(room: RoomData):
	var button = ROOM_BUTTON.instantiate()

	room_container.add_child(button)

	button.setup(room)
	
	button.disabled = !room.unlocked

	button.room_selected.connect(_on_room_selected)


func _on_room_selected(room):

	print("Attempting room:", room.room_id)


	if !map_manager.move_to_room(room):
		print("Invalid path")
		return


	print("Moving into room:", room.room_id)


	room_entered.emit(room)



	#match room.room_type:
		#RoomData.RoomType.ENEMY:
			#print("Starting enemy battle")
#
		#RoomData.RoomType.ELITE:
			#print("Starting elite battle")
#
		#RoomData.RoomType.MERCHANT_TRAP:
			#print("Merchant was a trap!")
			#print("Starting trap battle")
#
		#RoomData.RoomType.TREASURE:
			#print("Opening treasure")
#
		#RoomData.RoomType.REST:
			#print("Rest room")
#
		#RoomData.RoomType.MERCHANT:
			#print("Merchant")
#
		#RoomData.RoomType.LAB:
			#print("Laboratory")
#
		#RoomData.RoomType.BOSS:
			#print("BOSS FIGHT")
