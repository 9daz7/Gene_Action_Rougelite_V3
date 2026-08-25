extends Control
class_name MapUI


# ==================================================
# Managers
# ==================================================

@onready var map_manager: MapManager = get_node(
	"../../Managers/MapManager"
)

# ==================================================
# Map Settings
# ==================================================

@export var layer_spacing: float = 140.0
@export var node_spacing: float = 170.0

@export var map_margin := Vector2(120.0, 100.0)

@export var node_radius: float = 24.0
@export var connection_width: float = 5.0


# ==================================================
# Colors
# ==================================================

var current_node_color := Color(1.0, 0.85, 0.2)
var visited_node_color := Color(0.35, 0.85, 0.45)
var normal_node_color := Color(0.35, 0.55, 0.85)
var unknown_node_color := Color(0.18, 0.18, 0.18)

var connection_color := Color(0.45, 0.45, 0.45)
var visited_connection_color := Color(0.75, 0.85, 0.55)


# ==================================================
# State
# ==================================================

var visible_map := false


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	hide()

	visible_map = false

	if map_manager != null:

		if not map_manager.map_updated.is_connected(
			_on_map_updated
		):

			map_manager.map_updated.connect(
				_on_map_updated
			)


# ==================================================
# Input
# ==================================================

func _unhandled_input(
	event: InputEvent
) -> void:

	if event is InputEventKey:

		if not event.pressed:
			return

		if event.echo:
			return

		if event.keycode == KEY_TAB:

			toggle_map()

			get_viewport().set_input_as_handled()

			return

		if event.keycode == KEY_M:

			toggle_map()

			get_viewport().set_input_as_handled()

			return


# ==================================================
# Public Functions
# ==================================================

func toggle_map() -> void:

	if visible_map:

		close_map()

	else:

		open_map()


func open_map() -> void:

	if map_manager == null:

		push_error(
			"MapUI: MapManager is missing."
		)

		return

	visible_map = true

	show()

	queue_redraw()


func close_map() -> void:

	visible_map = false

	hide()


# ==================================================
# Map Update
# ==================================================

func _on_map_updated() -> void:

	if visible_map:

		queue_redraw()


# ==================================================
# Drawing
# ==================================================

func _draw() -> void:

	if map_manager == null:
		return

	var run_map := map_manager.run_map

	if run_map == null:
		return

	if run_map.layers.is_empty():
		return

	# ==================================================
	# Draw Connections
	# ==================================================

	_draw_connections(
		run_map
	)

	# ==================================================
	# Draw Nodes
	# ==================================================

	for layer in run_map.layers:

		for node in layer:

			if not map_manager.is_node_visible(
				node
			):

				continue

			_draw_node(
				node
			)


# ==================================================
# Draw Connections
# ==================================================

func _draw_connections(
	run_map: RunMapResource
) -> void:

	for node in run_map.all_nodes:

		if not map_manager.is_node_visible(
			node
		):

			continue

		var start_position := (
			_get_node_position(node)
		)

		for next_node in node.next_nodes:

			if next_node == null:

				continue

			var end_position := (
				_get_node_position(next_node)
			)

			var color := connection_color

			if node.visited and next_node.visited:

				color = visited_connection_color

			draw_line(
				start_position,
				end_position,
				color,
				connection_width,
				true
			)


# ==================================================
# Draw Node
# ==================================================

func _draw_node(
	node: RunMapNode
) -> void:

	var position := (
		_get_node_position(node)
	)

	var color := (
		_get_node_color(node)
	)

	draw_circle(
		position,
		node_radius,
		color
	)

	# ==================================================
	# Current Node Marker
	# ==================================================

	if node == map_manager.current_node:

		draw_arc(
			position,
			node_radius + 7.0,
			0.0,
			TAU,
			32,
			current_node_color,
			4.0,
			true
		)

	# ==================================================
	# Room Type
	# ==================================================

	if map_manager.is_node_type_visible(
		node
	):

		var room_name := (
			node.room.room_name
			if node.room != null
			else "Unknown"
		)

		var text_position := (
			position
			+ Vector2(
				-node_radius * 2.5,
				node_radius + 35.0
			)
		)

		draw_string(
			ThemeDB.fallback_font,
			text_position,
			room_name,
			HORIZONTAL_ALIGNMENT_CENTER,
			node_radius * 5.0,
			18,
			Color.WHITE
		)


# ==================================================
# Node Color
# ==================================================

func _get_node_color(
	node: RunMapNode
) -> Color:

	if node == map_manager.current_node:
		
		return current_node_color
		
	if node.visited:
		
		return visited_node_color

	# ==================================================
	# Currently reachable nodes
	# ==================================================

	if map_manager.current_node != null:

		if node in map_manager.current_node.next_nodes:

			return normal_node_color

	return unknown_node_color


# ==================================================
# Node Position
# ==================================================

func _get_node_position(
	node: RunMapNode
) -> Vector2:

	var layer := node.layer
	var index := node.index

	var layer_nodes: Array = (
		map_manager.run_map.layers[layer]
	)

	var count := layer_nodes.size()

	var center_x := size.x * 0.5

	var x := center_x

	if count > 1:

		var total_width := (
			(count - 1)
			* node_spacing
		)

		x += (
			index
			* node_spacing
			- total_width * 0.5
		)

	var y := (
	size.y
	- map_margin.y
	-  layer * layer_spacing
	)

	return Vector2(
		x,
		y
	)
