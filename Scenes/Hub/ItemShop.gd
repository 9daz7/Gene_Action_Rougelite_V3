extends StaticBody2D
class_name ItemShop


# ==================================================
# Interaction
# ==================================================

@onready var interactable: Interactable = $Interactable


# ==================================================
# Test Potion Stock
# ==================================================

const MAX_STOCK: int = 3

var health_stock: int = MAX_STOCK
var attack_stock: int = MAX_STOCK
var defense_stock: int = MAX_STOCK


# ==================================================
# Potion Resources
# ==================================================

const LARGE_HEALTH_POTION = preload(
	"res://Data/Potions/LargeHealthPotion.tres"
)

const SMALL_HEALTH_POTION = preload(
	"res://Data/Potions/SmallHealthPotion.tres"
)

const ATTACK_POTION = preload(
	"res://Data/Potions/AttackPotion.tres"
)

const DEFENSE_POTION = preload(
	"res://Data/Potions/DefensePotion.tres"
)

const SPEED_POTION = preload(
	"res://Data/Potions/SpeedPotion.tres"
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("Item SHOP READY")

	health_stock = MAX_STOCK
	attack_stock = MAX_STOCK
	defense_stock = MAX_STOCK

	if interactable == null:

		push_error(
			"ItemShop: Interactable node not found."
		)

		return

	if not interactable.interacted.is_connected(
		_open_shop
	):

		interactable.interacted.connect(
			_open_shop
	)


# ==================================================
# Open Shop
# ==================================================

func _open_shop() -> void:

	print("================================")
	print("POTION SHOP OPENED")
	print("================================")

	var shop_ui := get_tree().current_scene.get_node_or_null(
		"UI/ItemShopUI"
	)

	if shop_ui == null:

		push_error(
			"ItemShop: Could not find UI/ItemShopUI."
		)

		return

	shop_ui.open(
		self
	)


# ==================================================
# Purchase
# ==================================================

func buy_health_potion() -> bool:

	if health_stock <= 0:

		print("Health potion stock empty.")

		return false

	health_stock -= 1

	print(
		"Health potion purchased.",
		" Remaining:",
		health_stock
	)

	return true


func buy_attack_potion() -> bool:

	if attack_stock <= 0:

		print("Attack potion stock empty.")

		return false

	attack_stock -= 1

	print(
		"Attack potion purchased.",
		" Remaining:",
		attack_stock
	)

	return true


func buy_defense_potion() -> bool:

	if defense_stock <= 0:

		print("Defense potion stock empty.")

		return false

	defense_stock -= 1

	print(
		"Defense potion purchased.",
		" Remaining:",
		defense_stock
	)

	return true


# ==================================================
# Potion Access
# ==================================================

func get_health_potion() -> PotionResource:
	return SMALL_HEALTH_POTION


func get_attack_potion() -> PotionResource:
	return ATTACK_POTION


func get_defense_potion() -> PotionResource:
	return DEFENSE_POTION


func get_health_stock() -> int:
	return health_stock


func get_attack_stock() -> int:
	return attack_stock


func get_defense_stock() -> int:
	return defense_stock
