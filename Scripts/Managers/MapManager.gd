extends Node
class_name MapManager

signal map_generated

const  ROWS = 7
const ROOMS_PER_ROW = 3

var current_map:Array[RoomData] = []

var map_rows:Array = []

var current_world := 1

func generate_map():
	current_map.clear()
	map_rows.clear()
	
	# create rows
	for row in range(ROWS):
		
		var rooms:Array[RoomData] = []
		
		# BOSS row only has one room
		var room_count = ROOMS_PER_ROW
		
		if row == ROWS - 1:
			room_count = 1
			
		for lane in range(room_count):
			
			var room = RoomData.new()
			room.room_id = current_map.size()
			room.row = row
			room.lane = lane
			
			var x_spacing = 250
			var y_spacing = 110

			room.position = Vector2(
				250 + lane * x_spacing,
				700 - row * y_spacing
			)
			
			# BOSS
			if row == ROWS - 1:
				room.room_type = RoomData.RoomType.BOSS
			else:
				room.room_type = generate_room_type(row)
				
			rooms.append(room)
			current_map.append(room)
			
		map_rows.append(rooms)
		
	connect_paths()
	
	print_map()
	
	map_generated.emit()

#
# connect rooms together
#	

func connect_paths():
	for row in range(map_rows.size() - 1):
		var current_row = map_rows[row]
		var next_row = map_rows[row + 1]
		
		for room in current_row:
			# guarenteed path forward
			var next_room = find_closest_next_room(
				room,
				next_row
			)
			
			if next_room not in room.connections:
				room.connections.append(next_room)
			
			# chance to branch
			if randf() < 0.40:
				var extra = next_row.pick_random()
				
				if extra not in room.connections:
					room.connections.append(extra)
					
#
# keep paths naturally merging
#

func find_closest_next_room(room, next_row):
	var closest = next_row[0]
	var distance = abs(
		room.lane - closest.lane
	)
	
	for possible in next_row:
		var new_distance = abs(
			room.lane - possible.lane
		)
		
		if new_distance < distance:
			closest = possible
			distance = new_distance
			
	return closest
	
#
# room generation
#

func generate_room_type(row:int):
	var roll = randf()
	
	#
	# world 1
	#
	
	if current_world == 1:


		if row < 2:
			
			if roll < 0.55:
				return RoomData.RoomType.ENEMY
			elif roll < 0.75:
				return RoomData.RoomType.TREASURE
			elif roll < 0.9:
				return RoomData.RoomType.REST
			else:
				return RoomData.RoomType.UNKNOWN

		elif row < 5:
			if roll < 0.4:
				return RoomData.RoomType.ENEMY
			elif roll < 0.55:
				return RoomData.RoomType.ELITE
			elif roll < 0.7:
				return RoomData.RoomType.MERCHANT
			elif roll < 0.85:
				return RoomData.RoomType.LAB
			else:
				return RoomData.RoomType.UNKNOWN

		else:
			
			if roll < 0.4:
				return RoomData.RoomType.ELITE
			elif roll < 0.7:
				return RoomData.RoomType.ENEMY
			elif roll < 0.85:
				return RoomData.RoomType.LAB
			else:
				return RoomData.RoomType.REST
			
			
	#
	# world 2+
	#
	
	else:

		if row < 3:
			if roll < 0.55:
				return RoomData.RoomType.ENEMY
			elif roll < 0.7:
				return RoomData.RoomType.GROUP_ENEMY
			elif roll < 0.8:
				return RoomData.RoomType.AMBUSH
			else:
				return RoomData.RoomType.TREASURE



		else:

			if roll < 0.35:
				return RoomData.RoomType.ENEMY
			elif roll < 0.5:
				return RoomData.RoomType.ELITE
			elif roll < 0.65:
				return RoomData.RoomType.LAB
			elif roll < 0.75:
				return RoomData.RoomType.MERCHANT_TRAP
			elif roll < 0.9:
				return RoomData.RoomType.MERCHANT
			else:
				return RoomData.RoomType.UNKNOWN
	
			
func print_map():
	print("=========== MAP ==========")
	
	for row in map_rows:
		for room in row:
			print(
				"Room:",
				room.room_id,
				" Type:",
				room.room_type,
				" Row:",
				room.row,
				" Connections:",
				room.connections.size()
			)
			
	print("===========================")
	
