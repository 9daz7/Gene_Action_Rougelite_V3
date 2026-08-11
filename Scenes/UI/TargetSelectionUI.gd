extends PanelContainer
class_name TargetSelectionUI


@onready var button_container = $VBoxContainer

var enemies:Array[EnemyAnimal] = []


func _ready():

	hide()

	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_targets(
	targets:Array[EnemyAnimal]
):

	if targets.is_empty():
		print("No targets available")
		hide()
		return

	enemies = targets

	_clear_buttons()


	for enemy in enemies:

		if enemy.hp <= 0:
			continue

		var button := Button.new()

		button.text = (
			"Attack "
			+ enemy.get_display_name()
		)


		button.pressed.connect(
			func():
				select_target(enemy)
		)

		button_container.add_child(button)

	show()

	mouse_filter = Control.MOUSE_FILTER_STOP


func select_target(enemy:EnemyAnimal):

	if not visible:
		return

	if not is_instance_valid(enemy):
		return

	if enemy.hp <= 0:
		return

	print(
		"Target button selected:",
		enemy.name
	)

	hide()

	mouse_filter = Control.MOUSE_FILTER_IGNORE

	GameEvents.target_selected.emit(
		enemy
	)


func _clear_buttons():

	for child in button_container.get_children():

		child.queue_free()
