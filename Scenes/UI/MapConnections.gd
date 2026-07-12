extends Node2D


var map:Array[RoomData] = []


func set_map(new_map):

	map = new_map
	queue_redraw()



func _draw():

	for room in map:

		for connection in room.connections:

			draw_line(
				room.position + Vector2(40,20),
				connection.position + Vector2(40,20),
				Color.WHITE,
				4
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
