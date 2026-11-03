extends Button
class_name BuildSlot


signal slot_pressed(slot_index: int)


@onready var slot_name: Label = $SlotContent/SlotName
@onready var slot_description: Label = $SlotContent/SlotDescription


var slot_index: int = -1
var item_resource: Resource = null


func _ready() -> void:

	pressed.connect(_on_pressed)

	update_display()


func setup(
	index: int,
	resource: Resource = null
) -> void:

	slot_index = index
	item_resource = resource

	update_display()


func update_display() -> void:

	if not is_node_ready():
		return

	if item_resource == null:

		slot_name.text = "Empty Slot"
		slot_description.text = ""

	else:

		if item_resource is GeneResource:
			slot_name.text = item_resource.gene_name

		elif item_resource is MoveResource:
			slot_name.text = item_resource.move_name

		slot_description.text = item_resource.description


func _on_pressed() -> void:

	if item_resource == null:
		return

	slot_pressed.emit(slot_index)
