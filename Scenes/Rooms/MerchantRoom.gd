extends Control
class_name MerchantRoom


signal merchant_finished

#@onready var run_manager = $"../Managers/RunManager"
#@onready var save_manager = $"../Managers/SaveManager"
@onready var run_manager = get_tree().current_scene.get_node("Managers/RunManager")
@onready var save_manager = get_tree().current_scene.get_node("Managers/SaveManager")

@onready var gold_label = $CenterContainer/VBoxContainer/GoldLabel
@onready var item_container = $CenterContainer/VBoxContainer/ItemContainer
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton


var selected_item = null


const SHOP_BUTTON = preload("res://Scenes/UI/RewardButton.tscn")

const SHOP_ITEMS = [
	preload("res://Data/Shop/BoarSkinShop.tres"),
	preload("res://Data/Shop/HealShop.tres"),
	preload("res://Data/Shop/MutagenShop.tres")
]

func _ready():

	continue_button.pressed.connect(
		_on_continue_pressed
	)


func open():

	show()

	update_gold()

	create_shop_items()


func update_gold():

	gold_label.text = "Gold: " + str(
		save_manager.gold
	)


func create_shop_items():

	for child in item_container.get_children():
		child.queue_free()

	var items = SHOP_ITEMS

	for item in items:

		var button = SHOP_BUTTON.instantiate()
		
		if item.item_type == ShopItem.ItemType.GENE:

			if run_manager.owns_gene(item.gene):

				button.text = item.item_name + " - OWNED"
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
		
		button.custom_minimum_size = Vector2(
			300,
			60
		)

		button.pressed.connect(
			func():
				buy_item(item, button)
		)

		item_container.add_child(button)
	
	
func buy_item(item: ShopItem, button: Button):

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
		button.text = item.item_name + " - OWNED"
		button.disabled = true

	else:
		button.queue_free()

	update_gold()


func apply_item(item:ShopItem):

	match item.item_type:

		ShopItem.ItemType.ITEM:
			run_manager.heal_player(25)


		ShopItem.ItemType.GENE:
			run_manager.store_gene(item.gene)
			

		ShopItem.ItemType.MUTAGEN:
			print("Mutagen purchased")
			
	save_manager.save_game(run_manager)

func _on_continue_pressed():

	print("Merchant complete")

	merchant_finished.emit()
	
	queue_free()
