extends Resource
class_name ShopItem


enum ItemType
{
	GENE,
	ITEM,
	MUTAGEN
}


@export var item_name:String
@export var cost:int
@export var item_type:ItemType

@export var description:String
