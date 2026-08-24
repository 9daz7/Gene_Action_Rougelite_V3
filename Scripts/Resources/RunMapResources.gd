extends Resource
class_name RunMapResource


# ==================================================
# Graph
# ==================================================

var all_nodes: Array[RunMapNode] = []

var layers: Array = []


# ==================================================
# Start
# ==================================================

var start_node: RunMapNode = null


# ==================================================
# Current Position
# ==================================================

var current_node: RunMapNode = null


# ==================================================
# Utility
# ==================================================

func get_layer(
	layer_index: int
) -> Array:

	if layer_index < 0:
		return []

	if layer_index >= layers.size():
		return []

	return layers[layer_index]
