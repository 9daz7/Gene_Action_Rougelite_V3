extends RefCounted
class_name ItemShopData


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

const SMALL_HEALTH_POTION = preload(
	"res://Data/Potions/SmallHealthPotion.tres"
)

const ATTACK_POTION = preload(
	"res://Data/Potions/AttackPotion.tres"
)

const DEFENSE_POTION = preload(
	"res://Data/Potions/DefensePotion.tres"
)


# ==================================================
# Purchase
# ==================================================

func buy_health_potion() -> bool:

	if health_stock <= 0:
		return false

	health_stock -= 1
	return true


func buy_attack_potion() -> bool:

	if attack_stock <= 0:
		return false

	attack_stock -= 1
	return true


func buy_defense_potion() -> bool:

	if defense_stock <= 0:
		return false

	defense_stock -= 1
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


# ==================================================
# Stock Access
# ==================================================

func get_health_stock() -> int:

	return health_stock


func get_attack_stock() -> int:

	return attack_stock


func get_defense_stock() -> int:

	return defense_stock
