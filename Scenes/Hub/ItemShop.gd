extends StaticBody2D
class_name ItemShop


@onready var potion_storage: PotionStorageManager = get_node(
	"../../../Managers/PotionStorageManager"
)


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

	print(
		"Health:",
		health_stock,
	"| Attack:",
		attack_stock,
	"| Defense:",
		defense_stock
	)

	_buy_test_potion(
		SMALL_HEALTH_POTION,
		"Health"
	)

	_buy_test_potion(
		ATTACK_POTION,
		"Attack"
	)

	_buy_test_potion(
		DEFENSE_POTION,
		"Defense"
	)


# ==================================================
# Test Purchase
# ==================================================

func _buy_test_potion(
	potion: PotionResource,
	type_name: String
) -> void:

	if potion == null:
		return

	var stock := 0

	match type_name:

		"Health":
			stock = health_stock

		"Attack":
			stock = attack_stock

		"Defense":
			stock = defense_stock

	if stock <= 0:

		print(
			type_name,
			" potion stock empty."
		)

		return

	if potion_storage == null:

		push_error(
			"ItemShop: PotionStorageManager not found."
		)

		return

	potion_storage.add_potion(
		potion,
		1
	)

	match type_name:

		"Health":
			health_stock -= 1

		"Attack":
			attack_stock -= 1

		"Defense":
			defense_stock -= 1

	print(
		"Added to permanent storage:",
		potion.potion_name,
		"| Remaining:",
		stock - 1
	)
