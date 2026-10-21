extends Room3DBase
class_name MerchantRoom3D


# ==================================================
# Scenes
# ==================================================

const SHOP_UI_SCENE = preload(
	"res://Scenes/Rooms/MerchantRoom_UI.tscn"
)


# ==================================================
# References
# ==================================================

@onready var merchant_interactable: MerchantInteractable3D = (
	$MerchantInteractable
)

@onready var action_battle_ui: ActionBattleUI = (
	$ActionBattleUI
)


# ==================================================
# Managers
# ==================================================

var run_manager: RunManager = null
var room_manager: RoomManager = null


# ==================================================
# State
# ==================================================

var shop_ui: MerchantRoom_UI = null

var previous_mouse_mode: Input.MouseMode = (
	Input.MOUSE_MODE_VISIBLE
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	run_manager = get_node_or_null(
		"/root/Main/Managers/RunManager"
	) as RunManager

	room_manager = get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	if not is_instance_valid(merchant_interactable):
		push_error("MerchantRoom3D: MerchantInteractable is missing.")
		return

	if not is_instance_valid(action_battle_ui):
		push_error("MerchantRoom3D: ActionBattleUI is missing.")
		return

	if not is_instance_valid(run_manager):
		push_error("MerchantRoom3D: RunManager is missing.")
		return

	if not is_instance_valid(room_manager):
		push_error("MerchantRoom3D: RoomManager is missing.")
		return

	if not is_instance_valid(room_manager.player_character):
		push_error("MerchantRoom3D: Player character is missing.")
		return

	if not is_instance_valid(room_manager.deebo_character):
		push_error("MerchantRoom3D: Deebo character is missing.")
		return

	if not merchant_interactable.interacted.is_connected(
		_on_merchant_interacted
	):
		merchant_interactable.interacted.connect(
			_on_merchant_interacted
		)

	# Initialize the bars using the persistent characters' actual HP.
	action_battle_ui.setup(
		room_manager.player_character,
		room_manager.deebo_character
	)

	super._ready()
	complete_room()


# ==================================================
# Merchant
# ==================================================

func _on_merchant_interacted() -> void:

	if is_instance_valid(shop_ui):
		return

	if not is_instance_valid(run_manager):
		push_error("MerchantRoom3D: RunManager is missing.")
		return

	if not is_instance_valid(room_manager):
		push_error("MerchantRoom3D: RoomManager is missing.")
		return

	var player := room_manager.player_character

	if is_instance_valid(player) and player.has_method(
		"set_controls_enabled"
	):
		player.call("set_controls_enabled", false)

	var ui_layer := get_tree().current_scene.get_node_or_null("UI")

	if ui_layer == null:
		push_error("MerchantRoom3D: Main UI node is missing.")

		if is_instance_valid(player) and player.has_method(
			"set_controls_enabled"
		):
			player.call("set_controls_enabled", true)

		return

	shop_ui = SHOP_UI_SCENE.instantiate() as MerchantRoom_UI

	if shop_ui == null:
		push_error("MerchantRoom3D: Failed to create Merchant UI.")

		if is_instance_valid(player) and player.has_method(
			"set_controls_enabled"
		):
			player.call("set_controls_enabled", true)

		return

	ui_layer.add_child(shop_ui)

	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not shop_ui.merchant_finished.is_connected(
		_on_merchant_finished
	):
		shop_ui.merchant_finished.connect(
			_on_merchant_finished
		)

	shop_ui.open(run_manager)


# ==================================================
# Merchant Closed
# ==================================================

func _on_merchant_finished() -> void:

	print("SHOP UI CLOSED")

	if is_instance_valid(shop_ui):
		shop_ui.queue_free()
		shop_ui = null

	if is_instance_valid(room_manager):
		var player := room_manager.player_character

		if is_instance_valid(player) and player.has_method(
			"set_controls_enabled"
		):
			player.call("set_controls_enabled", true)

	Input.mouse_mode = previous_mouse_mode
