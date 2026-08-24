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
# Initialization
# ==================================================

func _ready() -> void:

	print("MAP MANAGER READY")


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
# Node Visibility
# ==================================================

func is_node_visible(
	node: RunMapNode
) -> bool:

	if node == null:
		return false

	# ==================================================
	# Current room
	# ==================================================

	if node == current_node:

		return true

	# ==================================================
	# Previously visited
	# ==================================================

	if node.visited:

		return true

	# ==================================================
	# Immediate exits
	# ==================================================

	if current_node != null:

		if node in current_node.next_nodes:

			return true

	return false


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
