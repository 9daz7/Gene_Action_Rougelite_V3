extends Node
class_name MapManager


# ==================================================
# Signals
# ==================================================

signal map_updated


# ==================================================
# Run Map
# ==================================================

var run_map: RunMapResource = null


# ==================================================
# Current Node
# ==================================================

var current_node: RunMapNode = null


# ==================================================
# Scanner State
# ==================================================

var scanner_enabled: bool = false
var scanner_view_range: int = 0


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("MAP MANAGER READY")



func enable_scanner() -> void:

	scanner_enabled = true

	print("SCANNER ENABLED")

	map_updated.emit()


func disable_scanner() -> void:

	scanner_enabled = false

	print("SCANNER DISABLED")

	map_updated.emit()


# ==================================================
# Run Map Setup
# ==================================================

func set_run_map(
	new_run_map: RunMapResource
) -> void:

	run_map = new_run_map

	if run_map == null:

		current_node = null

		push_error(
			"MapManager: Received null RunMapResource."
		)

		return

	current_node = run_map.current_node

	print("================================")
	print("MAP MANAGER: RUN MAP SET")
	print("================================")

	print(
		"Total nodes:",
		run_map.all_nodes.size()
	)

	if current_node != null:

		print(
			"Current room:",
			current_node.room.room_name
		)

	map_updated.emit()


# ==================================================
# Current Node
# ==================================================

func set_current_node(
	node: RunMapNode
) -> void:

	if node == null:

		push_error(
			"MapManager: Cannot set null current node."
		)

		return

	current_node = node

	if run_map != null:

		run_map.current_node = node

	print(
		"MAP CURRENT NODE:",
		node.room.room_name
	)

	map_updated.emit()


# ==================================================
# Available Paths
# ==================================================

func get_available_nodes() -> Array[RunMapNode]:

	if current_node == null:

		return []

	return current_node.next_nodes


# ==================================================
# Visited Path
# ==================================================

func get_visited_nodes() -> Array[RunMapNode]:

	var visited: Array[RunMapNode] = []

	if run_map == null:

		return visited

	for node in run_map.all_nodes:

		if node.visited:

			visited.append(node)

	return visited


# ==================================================
# Room Type Visibility
# ==================================================

func get_visible_room_type(
	node: RunMapNode
) -> RoomResource.RoomType:

	if node == null:

		return RoomResource.RoomType.BATTLE

	if node == current_node:

		return node.room.room_type

	if node.visited:

		return node.room.room_type

	# ==================================================
	# Future upgrade system
	# ==================================================

	return RoomResource.RoomType.BATTLE

# ==================================================
# Map State
# ==================================================

func mark_current_node_complete() -> void:

	if current_node == null:

		return

	current_node.completed = true

	map_updated.emit()


# ==================================================
# Scanner Upgrades
# ==================================================


func increase_scanner_view_range() -> void:

	scanner_view_range += 1

	print(
		"Map view range increased to:",
		scanner_view_range
	)

	map_updated.emit()


# ==================================================
# Node Visibility
# ==================================================


func is_node_visible(
	node: RunMapNode
) -> bool:

	if not scanner_enabled:

		return false

	if node == null:

		return false

	if current_node == null:

		return false

	# ==================================================
	# Completed / current layers
	# ==================================================

	if node.layer <= current_node.layer:

		return true

	# ==================================================
	# Future scan range
	# ==================================================

	var layer_difference := (
		node.layer
		- current_node.layer
	)

	return layer_difference <= scanner_view_range


func is_node_type_visible(
	node: RunMapNode
) -> bool:

	if not scanner_enabled:

		return false

	if node == null:

		return false

	if current_node == null:

		return false

	# ==================================================
	# Completed/current  layers
	# ==================================================

	if node.layer <= current_node.layer:

		return true

	# ==================================================
	# Future scan range
	# ==================================================

	var layer_difference := (
		node.layer
		- current_node.layer
	)

	return layer_difference <= scanner_view_range


# ==================================================
# Debug
# ==================================================

func print_current_map() -> void:

	if run_map == null:

		print(
			"MapManager: No RunMapResource."
		)

		return

	print("================================")
	print("CURRENT RUN MAP")
	print("================================")

	for node in run_map.all_nodes:

		print(
			"Layer:",
			node.layer,
			" Node:",
			node.index,
			" Room:",
			node.room.room_name,
			" Visited:",
			node.visited,
			" Completed:",
			node.completed
		)
