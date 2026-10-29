extends Node3D
class_name HubWorld3D

signal animal_lab_requested

var is_open: bool = false
var run_manager: Node = null
var gene_database: Node = null

var potion_storage_ui: PotionStorageUI = null
var item_shop_ui: ItemShopUI = null
var item_shop_data: ItemShopData = ItemShopData.new()
var upgrade_shop_ui: UpgradeShopUI = null

var hub_player_start_transform: Transform3D
var hub_player_start_transform_saved: bool = false


func setup(
	p_run_manager: Node,
	p_gene_database: Node,
	p_potion_storage_ui: PotionStorageUI = null,
	p_item_shop_ui: ItemShopUI = null,
	p_upgrade_shop_ui: UpgradeShopUI = null
) -> void:

	run_manager = p_run_manager
	gene_database = p_gene_database

	potion_storage_ui = p_potion_storage_ui
	item_shop_ui = p_item_shop_ui
	upgrade_shop_ui = p_upgrade_shop_ui


func open() -> void:

	is_open = true
	process_mode = Node.PROCESS_MODE_INHERIT

	var player := get_node_or_null(
		"HubPlayer3D/Player"
	) as HubPlayer3D

	if player != null:
		# Restore the original hub spawn position.
		if hub_player_start_transform_saved:
			player.global_transform = hub_player_start_transform

		# Clear any stale interaction.
		player.set_nearby_interactable(null)

		# Re-enable movement and interaction.
		player.set_controls_enabled(true)
	else:
		push_warning(
			"HubWorld3D: Could not find the hub player."
		)

	show()


func close() -> void:

	is_open = false

	var player := get_node_or_null("HubPlayer3D/Player") as HubPlayer3D

	if player != null:
		player.set_controls_enabled(false)
		player.set_nearby_interactable(null)

	hide()


func _ready() -> void:

	_connect_building("House", "_on_storage_interacted")
	_connect_building("ItemShop", "_on_item_shop_interacted")
	_connect_building("UpgradeShop", "_on_upgrade_shop_interacted")
	_connect_building("AnimalLab", "_on_animal_lab_interacted")

	var player := get_node_or_null(
		"HubPlayer3D/Player"
	) as HubPlayer3D

	if player != null:
		hub_player_start_transform = player.global_transform
		hub_player_start_transform_saved = true
	else:
		push_warning(
			"HubWorld3D: Could not save the player spawn transform."
		)


func _connect_building(
	building_name: String,
	callback_name: String
) -> void:

	var area := get_node_or_null(
		"Buildings/" + building_name + "/Area3D"
	) as HubInteractable3D

	if area == null:
		push_error(
			"HubWorld3D: Missing Area3D for " + building_name
		)
		return

	var callback := Callable(self, callback_name)

	if not area.interacted.is_connected(callback):
		area.interacted.connect(callback)


func _on_storage_interacted() -> void:

	print("STORAGE CALLBACK RECEIVED")

	if potion_storage_ui == null:
		push_warning(
			"HubWorld3D: PotionStorageUI has not been assigned."
		)
		return

	potion_storage_ui.open()


func _on_item_shop_interacted() -> void:

	print("HubWorld3D: Item Shop callback received")

	if item_shop_ui == null:
		push_warning("HubWorld3D: ItemShopUI has not been assigned.")
		return

	item_shop_ui.open(item_shop_data)


func _on_upgrade_shop_interacted() -> void:

	print("HubWorld3D: Upgrade shop requested")

	if upgrade_shop_ui == null:
		push_warning(
			"HubWorld3D: UpgradeShopUI has not been assigned."
		)
		return

	upgrade_shop_ui.open()


func _on_animal_lab_interacted() -> void:

	animal_lab_requested.emit()
