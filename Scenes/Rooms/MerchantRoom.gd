extends RoomWorld
class_name MerchantRoom


# ==================================================
# Scenes
# ==================================================

const SHOP_UI_SCENE = preload(
	"res://Scenes/Rooms/MerchantRoom_UI.tscn"
)


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = get_node(
	"../Managers/RunManager"
)


# ==================================================
# Interaction
# ==================================================

@onready var merchant_interactable: Interactable = $MerchantInteractable


# ==================================================
# State
# ==================================================

var shop_ui: Control = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	if not merchant_interactable.interacted.is_connected(
		_on_merchant_interacted
	):

		merchant_interactable.interacted.connect(
			_on_merchant_interacted
	)


# ==================================================
# Merchant
# ==================================================

func _on_merchant_interacted() -> void:

	if is_instance_valid(shop_ui):
		return

	if room_player != null:

		room_player.set_controls_enabled(
			false
		)

	shop_ui = SHOP_UI_SCENE.instantiate()

	get_tree().current_scene.get_node("UI").add_child(
		shop_ui
	)

	if shop_ui is Control:

		shop_ui.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

	if not shop_ui.merchant_finished.is_connected(
		_on_merchant_finished
	):

		shop_ui.merchant_finished.connect(
			_on_merchant_finished
		)

	shop_ui.open(
		run_manager
	)


# ==================================================
# Merchant Closed
# ==================================================

func _on_merchant_finished() -> void:

	print("SHOP UI CLOSED")

	if is_instance_valid(shop_ui):

		shop_ui.queue_free()

		shop_ui = null

	if room_player != null:

		room_player.set_controls_enabled(
			true
		)
