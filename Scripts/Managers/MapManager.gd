extends Node
class_name MapManager


# ==================================================
# Signals
# ==================================================


signal map_generated


# ==================================================
# Constants
# ==================================================


const ROWS = 8
const ROOMS_PER_ROW = 3

const X_SPACING := 250
const Y_SPACING := 110
const DEFAULT_X := 500

const STABLE_LAB = preload("res://Data/Labs/StableLab.tres")
const UNSTABLE_LAB = preload("res://Data/Labs/UnstableLab.tres")
const CRITICAL_LAB = preload("res://Data/Labs/CriticalLab.tres")


# ==================================================
# Member Variables
# ==================================================



var current_map: Array[RoomData] = []

var map_rows: Array = []

var current_world := 1

var current_room: RoomData = null


# ==================================================
# Initialization
# ==================================================

func _ready():
	pass


# ==================================================
# Public Functions
# ==================================================


func generate_map() -> void:
	
	current_map.clear()
	map_rows.clear()

	# Create rows
	for row in range(ROWS):
		
		var rooms: Array[RoomData] = []

		var room_count = ROOMS_PER_ROW
		
		# staring node
		if row == 0:
			room_count = 1
		
		# boss node
		elif row == ROWS - 1:
			room_count = 1

		for lane in range(room_count):
			
			var room = RoomData.new()

			room.room_id = current_map.size()
			room.row = row
			room.lane = lane


			var x := DEFAULT_X

			if room_count > 1:
				x = 250 + lane * X_SPACING

			room.position = Vector2(
				x,
				760 - row * Y_SPACING
			)
				
			if row == 0:
				room.room_type = RoomData.RoomType.START
			elif row == ROWS - 1:
				room.room_type = RoomData.RoomType.BOSS
			else:
				room.room_type = generate_room_type(row)
				
				if room.room_type == RoomData.RoomType.ABANDONED_LAB:
					room.lab_data = generate_lab_type()

			rooms.append(room)
			current_map.append(room)

		map_rows.append(rooms)

	connect_paths()
	
	print_map()
	
	set_starting_room()
	
	map_generated.emit()


func move_to_room(room: RoomData) -> bool:

	if current_room == null:
		print("Cannot move: current room is null")
		return false

	if room not in current_room.connections:
	
		print(
			"Cannot move from",
			current_room.room_id,
			"to",
			room.room_id
		)

		return false

	current_room = room

	current_room.visited = true

	update_available_rooms()

	return true


func complete_current_room() -> void:
	
	if current_room == null:
		print("Cannot complete room: current room is null")
		return
	
	current_room.completed = true
	
	print(
		"ROOM COMPLETED:",
		current_room.room_id
	)
	
	update_available_rooms()


func generate_lab_type() -> LabResource:

	var roll := randf()

	if roll < 0.33:
		return STABLE_LAB

	elif roll < 0.66:
		return UNSTABLE_LAB

	else:
		return CRITICAL_LAB
		
		
# ==================================================
# Private Functions
# ==================================================


func connect_paths() -> void:
	
	# connect START to first row
	var start_room = map_rows[0][0]

	for room in map_rows[1]:
		
		start_room.connections.append(room)


	# connect normal rows
	for row in range(1, ROWS - 2):

		var current_row = map_rows[row]
		var next_row = map_rows[row + 1]

		for room in current_row:

			# Always connect forward
			var closest = find_closest_next_room(
				room,
				next_row
			)

			if closest not in room.connections:
				room.connections.append(closest)


			# Add possible branch
			if randf() < 0.50:

				var branch = next_row.pick_random()

				if branch not in room.connections:
					room.connections.append(branch)



	# connect last row to boss
	var last_row = map_rows[ROWS - 2]
	var boss = map_rows[ROWS - 1][0]


	for room in last_row:

		if boss not in room.connections:
			room.connections.append(boss)


func generate_room_type(row: int):

	var roll := randf()

# World 1
	if current_world == 1:
		if row < 2:
			if roll < 0.55:
				return RoomData.RoomType.ENEMY
				
			elif roll < 0.6:
				return RoomData.RoomType.GROUP_ENEMY

			elif roll < 0.75:
				return RoomData.RoomType.TREASURE

			elif roll < 0.9:
				return RoomData.RoomType.REST

			else:
				return RoomData.RoomType.MYSTERY_ROOM


		elif row < 5:
			if roll < 0.4:
				return RoomData.RoomType.ENEMY

			elif roll < 0.55:
				return RoomData.RoomType.ELITE

			elif roll < 0.7:
				return RoomData.RoomType.MERCHANT

			elif roll < 0.85:
				return RoomData.RoomType.ABANDONED_LAB

			else:
				return RoomData.RoomType.MYSTERY_ROOM


		else:
			if roll < 0.4:
				return RoomData.RoomType.ELITE

			elif roll < 0.7:
				return RoomData.RoomType.ENEMY

			elif roll < 0.85:
				return RoomData.RoomType.ABANDONED_LAB

			else:
				return RoomData.RoomType.REST


	# World 2+
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
				return RoomData.RoomType.ABANDONED_LAB

			elif roll < 0.75:
				return RoomData.RoomType.MERCHANT_TRAP

			elif roll < 0.9:
				return RoomData.RoomType.MERCHANT

			else:
				return RoomData.RoomType.MYSTERY_ROOM
	

# ==================================================
# Helpers
# ==================================================


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


func print_map() -> void:
	
	print("=========== MAP ==========")

	for row in map_rows:
		
		for room in row:
			
			print(
				"Room:",
				room.room_id,
				" Type:",
				room.room_type,
				" Lab:",
				room.lab_data.lab_name if room.lab_data != null else "None",
				" Row:",
				room.row,
				" Connections:",
				room.connections.size()
			)

	print("===========================")
	
	
func set_starting_room() -> void:

	current_room = map_rows[0][0]

	print(
		"STARTING ROOM:",
		current_room.room_id
	)

	current_room.visited = true

	update_available_rooms()
	
	
func update_available_rooms() -> void:

	for room in current_map:
		
		room.available = false


	if current_room == null:
		return


	for next_room in current_room.connections:
		
		next_room.available = true
