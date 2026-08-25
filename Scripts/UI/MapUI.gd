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
# Scroll
# ==================================================

@export var scroll_speed: float = 80.0

var scroll_offset_y: float = 0.0


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	hide()

	visible_map = false

	clip_contents = true

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

	# ==================================================
	# Keyboard
	# ==================================================

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
	# Mouse Wheel
	# ==================================================

	if not visible_map:
		return

	if event is InputEventMouseButton:

		if not event.pressed:
			return

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:

			scroll_offset_y -= scroll_speed

			_clamp_scroll()

			queue_redraw()

			get_viewport().set_input_as_handled()

			return

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:

			scroll_offset_y += scroll_speed

			_clamp_scroll()

			queue_redraw()

			get_viewport().set_input_as_handled()

			return


func _clamp_scroll() -> void:

	if map_manager == null:
		return

	if map_manager.run_map == null:
		scroll_offset_y = 0.0
		return

	if map_manager.run_map.layers.is_empty():
		scroll_offset_y = 0.0
		return


	# ==================================================
	# Map Bounds
	# ==================================================

	var layer_count: int = (
		map_manager.run_map.layers.size()
	)

	var first_layer_y: float = (
		size.y
		- map_margin.y
	)

	var last_layer_y: float = (
		first_layer_y
		- (layer_count - 1) * layer_spacing
	)

	# ==================================================
	# Desired Screen Bounds
	# ==================================================

	var min_scroll: float = (
		last_layer_y
		- (size.y - map_margin.y)
	)

	var max_scroll: float = (
		first_layer_y
		- map_margin.y
	)


	scroll_offset_y = clamp(
		scroll_offset_y,
		min_scroll,
		max_scroll
	)


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

	if map_manager.run_map == null:

		print(
			"SCANNER HAS NO ACTIVE RUN MAP"
		)

		return

	visible_map = true

	show()

	_center_on_current_node()

	queue_redraw()


func _center_on_current_node() -> void:

	if map_manager == null:
		return

	if map_manager.run_map == null:
		return

	if map_manager.current_node == null:
		return


	var node := map_manager.current_node

	# ==================================================
	# Position without scrolling
	# ==================================================

	var base_y: float = (
		size.y
		- map_margin.y
		- node.layer * layer_spacing
	)


	# ==================================================
	# Center current node in the scanner
	# ==================================================

	var target_y: float = (
		size.y * 0.5
	)

	scroll_offset_y = (
		base_y - target_y
	)

	_clamp_scroll()

	queue_redraw()


func close_map() -> void:

	visible_map = false

	hide()


# ==================================================
# Map Update
# ==================================================

func _on_map_updated() -> void:

	if map_manager == null:
		return

	if map_manager.current_node == null:
		return

	if visible_map:

		_center_on_current_node()

	else:

		_clamp_scroll()


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

			if not map_manager.is_node_visible(
				next_node
			):

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
		- layer * layer_spacing
		- scroll_offset_y

	)

	return Vector2(
		x,
		y
	)
