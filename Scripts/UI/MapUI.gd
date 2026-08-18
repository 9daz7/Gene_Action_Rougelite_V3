extends Control
class_name MapUI


signal room_entered(room)


@onready var map_manager = $"../../Managers/MapManager"
@onready var room_container = $RoomContainer
@onready var connections = $Connections
@onready var player_marker = $PlayerMarker


const ROOM_BUTTON = preload("res://Scenes/UI/RoomButton.tscn")


var map:Array[RoomData] = []

var map_scale := 0.8

var map_offset := Vector2(500, 350)

func display_map(generated_map):

	map = generated_map

	clear_map()

	room_container.scale = Vector2.ONE * map_scale
	connections.scale = Vector2.ONE * map_scale
	
	room_container.position = map_offset
	connections.position = map_offset

	for room in map:
		create_room_button(room)


	connections.set_map(map)
	
	queue_redraw()


func clear_map():

	for child in room_container.get_children():
		child.queue_free()


func update_player_position(room: RoomData):

	if map_manager.current_room == null:
		return

	player_marker.position = (
		map_manager.current_room.position 
		+ Vector2(40,25)
	)
	
	
func create_room_button(room:RoomData):

	var button = ROOM_BUTTON.instantiate()

	room_container.add_child(button)

	button.setup(room)

	button.disabled = (
		!room.available 
		or room.completed
	)

	button.room_selected.connect(_on_room_selected)



func _on_room_selected(room):

	print("Clicked:", room.room_id)

	if not map_manager.move_to_room(room):
		print("Invalid path")
		return


	print("Entered:", room.room_id)

	print("EMITTING ROOM:", room.room_type)
	
	update_player_position(room)
	
	room_entered.emit(room)
