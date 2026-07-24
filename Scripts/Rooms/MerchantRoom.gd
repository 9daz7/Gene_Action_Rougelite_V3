extends Control
class_name MerchantRoom


# ==================================================
# Signals
# ==================================================

signal merchant_finished


# ==================================================
# Onready Variables
# ==================================================

@onready var gold_label = $CenterContainer/VBoxContainer/GoldLabel
@onready var item_container = $CenterContainer/VBoxContainer/ItemContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton


# ==================================================
# Constants
# ==================================================

const SHOP_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")

const SHOP_ITEMS = [
	preload("res://Data/Shop/BoarSkinShop.tres"),
	preload("res://Data/Shop/HealShop.tres"),
	preload("res://Data/Shop/MutagenShop.tres")
]


# ==================================================
# Member Variables
# ==================================================

var run_manager: RunManager
var save_manager: SaveManager

var selected_item: ShopItem = null


# ==================================================
# Initialization
# ==================================================


func _ready():

	continue_button.pressed.connect(
		_on_continue_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(manager:RunManager):

	run_manager = manager
	save_manager = manager.save_manager

	show()

	update_gold()

	create_shop_items()


func close():

	hide()


# ==================================================
# Shop Setup
# ==================================================


func update_gold():

	gold_label.text = "Gold: " + str(
		save_manager.gold
	)


func create_shop_items():

	for child in item_container.get_children():
		child.queue_free()


	for item in SHOP_ITEMS:

		var button = SHOP_BUTTON.instantiate()

		button.custom_minimum_size = Vector2(
			300,
			60
		)

		if item.item_type == ShopItem.ItemType.GENE:

			if run_manager.owns_gene(item.gene):

				button.text = (item.item_name + " - OWNED")
				
				button.disabled = true
				
			else:
				
				button.text = (
					item.item_name 
					+ " - "
					+ str(item.cost)
					+ " Gold"
				)
				
		else:
			button.text = (
				item.item_name
				+ " - "
				+ str(item.cost)
				+ " Gold"
			)

		button.pressed.connect(
			func():
				buy_item(item, button)
		)

		item_container.add_child(button)


# ==================================================
# Purchasing
# ==================================================


func buy_item(item:ShopItem, button:Button):

	if item.item_type == ShopItem.ItemType.GENE:
		
		if run_manager.owns_gene(item.gene):
			
			print("Already owned:", item.item_name)
			
			return

	print("Trying to buy:", item.item_name)
	
	if not run_manager.spend_gold(item.cost):
		
		print("Cannot afford:", item.item_name)
		
		return

	print("Bought:", item.item_name)

	selected_item = item
	
	apply_item(item)
	
	if item.item_type == ShopItem.ItemType.GENE:
		
		button.text = (item.item_name + " - OWNED")
		
		button.disabled = true

	else:
		
		button.queue_free()

	update_gold()


func apply_item(item:ShopItem):

	match item.item_type:

		ShopItem.ItemType.ITEM:

			run_manager.heal_player(25)

		ShopItem.ItemType.GENE:

			run_manager.unlock_gene(item.gene)


		ShopItem.ItemType.MUTAGEN:

			print("Mutagen purchased")

	save_manager.save_game(run_manager)


# ==================================================
# Private Functions
# ==================================================


func _on_continue_pressed():

	print("Merchant complete")

	merchant_finished.emit()
	
	queue_free()
