extends RefCounted
class_name RunMapNode


# ==================================================
# Room
# ==================================================

var room: RoomResource = null


# ==================================================
# Graph Position
# ==================================================

var layer: int = 0
var index: int = 0
var column: int = 0


# ==================================================
# State
# ==================================================

var visited: bool = false
var completed: bool = false


# ==================================================
# Connections
# ==================================================

var next_nodes: Array[RunMapNode] = []
var previous_nodes: Array[RunMapNode] = []


# ==================================================
# Initialization
# ==================================================

func _init(
	room_resource: RoomResource,
	layer_index: int,
	node_index: int,
	column_index: int = 0
) -> void:

	room = room_resource
	layer = layer_index
	index = node_index
	column = column_index


# ==================================================
# Connections
# ==================================================

func connect_to(
	node: RunMapNode
) -> void:

	if node == null:

		return

	if next_nodes.has(node):

		return

	next_nodes.append(
		node
	)

	if not node.previous_nodes.has(self):

		node.previous_nodes.append(
			self
	)


# ==================================================
# Identification
# ==================================================

func get_id() -> String:

	return str(layer) + "_" + str(index)
