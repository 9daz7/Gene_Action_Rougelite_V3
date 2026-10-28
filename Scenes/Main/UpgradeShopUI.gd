extends Control
class_name UpgradeShopUI


# ==================================================
# Signals
# ==================================================

signal purchase_completed


# ==================================================
# UI References
# ==================================================

@onready var currency_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CurrencyLabel
@onready var level_label: Label = $PanelContainer/MarginContainer/VBoxContainer/LevelLabel
@onready var description_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var cost_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CostLabel
@onready var purchase_button: Button = $PanelContainer/MarginContainer/VBoxContainer/PurchaseButton
@onready var status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	purchase_button.pressed.connect(_on_purchase_pressed)
	close_button.pressed.connect(_on_close_pressed)

	hide()


# ==================================================
# Open Shop
# ==================================================

func open() -> void:

	status_label.text = ""
	refresh_ui()
	show()


# ==================================================
# Refresh UI
# ==================================================

func refresh_ui() -> void:

	var currency: int = PermanentProgressionManager.permanent_currency
	var level: int = PermanentProgressionManager.map_upgrade_level
	var max_level: int = PermanentProgressionManager.MAX_MAP_UPGRADE_LEVEL

	currency_label.text = "Permanent Currency: %d" % currency
	level_label.text = "Upgrade Level: %d / %d" % [level, max_level]

	match level:
		0:
			description_label.text = "Reveal one additional layer of upcoming rooms on the map."
		1:
			description_label.text = "Reveal two additional layers of upcoming rooms on the map."
		_:
			description_label.text = "Maximum level reached. All available map visibility is unlocked."

	if level >= max_level:
		cost_label.text = "Cost: MAX LEVEL"
		purchase_button.text = "Fully Upgraded"
		purchase_button.disabled = true
	else:
		var cost: int = PermanentProgressionManager.get_map_upgrade_cost()
		cost_label.text = "Upgrade Cost: %d" % cost
		purchase_button.text = "Purchase Upgrade"
		purchase_button.disabled = currency < cost


# ==================================================
# Purchase
# ==================================================

func _on_purchase_pressed() -> void:

	var success: bool = PermanentProgressionManager.purchase_map_upgrade()

	if success:
		status_label.text = "Map scanner upgraded!"
		purchase_completed.emit()
	else:
		status_label.text = "Unable to purchase upgrade."

	refresh_ui()


# ==================================================
# Close Shop
# ==================================================

func _on_close_pressed() -> void:

	hide()
