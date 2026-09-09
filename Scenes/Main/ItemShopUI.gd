extends Control
class_name ItemShopUI


# ==================================================
# Managers
# ==================================================

@onready var potion_storage: PotionStorageManager = (
	get_node("../../Managers/PotionStorageManager")
)

@onready var run_manager: RunManager = (
	get_node("../../Managers/RunManager")
)

# ==================================================
# UI
# ==================================================

@onready var health_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/HealthButton
)

@onready var attack_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/AttackButton
)

@onready var defense_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/DefenseButton
)

@onready var close_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/CloseButton
)


# ==================================================
# State
# ==================================================

var current_shop: ItemShop = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	health_button.pressed.connect(
		_buy_health
	)

	attack_button.pressed.connect(
		_buy_attack
	)

	defense_button.pressed.connect(
		_buy_defense
	)

	close_button.pressed.connect(
		_close
	)

	hide()


# ==================================================
# Open
# ==================================================

func open(shop: ItemShop) -> void:

	if shop == null:

		push_error(
			"ItemShopUI: Cannot open with null shop."
		)

		return

	current_shop = shop

	print("================================")
	print("ITEM SHOP UI OPENED")
	print("================================")

	_refresh()

	show()


# ==================================================
# Refresh
# ==================================================

func _refresh() -> void:

	if current_shop == null:
		return

	health_button.text = (
		"Health Potion × "
		+ str(current_shop.get_health_stock())
		+ "    FREE"
	)

	attack_button.text = (
		"Attack Potion × "
		+ str(current_shop.get_attack_stock())
		+ "    FREE"
	)

	defense_button.text = (
		"Defense Potion × "
		+ str(current_shop.get_defense_stock())
		+ "    FREE"
	)

	health_button.disabled = (
		current_shop.get_health_stock() <= 0
	)

	attack_button.disabled = (
		current_shop.get_attack_stock() <= 0
	)

	defense_button.disabled = (
		current_shop.get_defense_stock() <= 0
	)


# ==================================================
# Buy Health
# ==================================================

func _buy_health() -> void:

	if current_shop == null:
		return

	if potion_storage == null:

		push_error(
			"ItemShopUI: PotionStorageManager not found."
		)

		return

	if not current_shop.buy_health_potion():
		return

	_store_purchased_potion(
		current_shop.get_health_potion()
	)

	print(
		"Purchased:",
		current_shop.get_health_potion().potion_name
	)

	_refresh()


# ==================================================
# Buy Attack
# ==================================================

func _buy_attack() -> void:

	if current_shop == null:
		return

	if potion_storage == null:

		push_error(
			"ItemShopUI: PotionStorageManager not found."
		)

		return

	if not current_shop.buy_attack_potion():
		return

	_store_purchased_potion(
		current_shop.get_attack_potion()
	)

	print(
		"Purchased:",
		current_shop.get_attack_potion().potion_name
	)

	_refresh()


# ==================================================
# Buy Defense
# ==================================================

func _buy_defense() -> void:

	if current_shop == null:
		return

	if potion_storage == null:

		push_error(
			"ItemShopUI: PotionStorageManager not found."
		)

		return

	if not current_shop.buy_defense_potion():
		return

	_store_purchased_potion(
		current_shop.get_defense_potion()
	)

	print(
		"Purchased:",
		current_shop.get_defense_potion().potion_name
	)

	_refresh()


# ==================================================
# Store Purchased Potion
# ==================================================

func _store_purchased_potion(
	potion: PotionResource
) -> void:

	if potion == null:
		return

	if run_manager == null:

		push_error(
			"ItemShopUI: RunManager not found."
		)

		return

	# ==================================================
	# Purchased in Hub
	# ==================================================

	if run_manager.add_potion_to_run(
		potion,
		true
	):

		print(
			"Purchased potion added to Player's Pocket:",
			potion.potion_name,
			"| From Hub: true"
		)

		return

	# ==================================================
	# Pocket Full -> Permanent Storage
	# ==================================================

	if potion_storage == null:

		push_error(
			"ItemShopUI: PotionStorageManager not found."
		)

		return

	potion_storage.add_potion(
		potion
	)

	print(
		"Player's Pocket full. "
		+ "Purchased potion added to permanent storage:",
		potion.potion_name
	)


# ==================================================
# Close
# ==================================================

func _close() -> void:

	current_shop = null

	hide()
