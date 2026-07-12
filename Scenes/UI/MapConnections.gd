extends Node2D


var map:Array[RoomData] = []


func set_map(new_map):

	map = new_map
	position = Vector2.ZERO
	queue_redraw()


func _draw():

	print("DRAWING CONNECTIONS:", map.size())

	for room in map:

		for connection in room.connections:

			print(
				room.room_id,
				" -> ",
				connection.room_id
			)

			draw_line(
				room.position + Vector2(40,25),
				connection.position + Vector2(40,25),
				Color.WHITE,
				5
			)
	#for room in map:
#
		#for connection in room.connections:
#
			#draw_line(
				#room.position + Vector2(40,25),
				#connection.position + Vector2(40,25),
				#Color.WHITE,
				#3
			#)
