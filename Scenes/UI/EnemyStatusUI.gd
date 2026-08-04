extends VBoxContainer
class_name EnemyStatusUI


@onready var name_label = $NameLabel
@onready var hp_bar = $HPBar
@onready var status_label = $StatusLabel

var enemy: EnemyAnimal


#func _ready():
#
	#mouse_filter = Control.MOUSE_FILTER_PASS
#
	#gui_input.connect(
		#_on_gui_input
	#)


func setup(enemy_ref:EnemyAnimal):

	enemy = enemy_ref

	name_label.text = enemy.get_display_name()

	hp_bar.max_value = enemy.get_max_hp()
	hp_bar.value = enemy.hp

	status_label.text = ""

	enemy.status_changed.connect(
		update_status
	)

	update_status()

#func select():
#
	#modulate = Color(1,1,0.5)
#
#
#func deselect():
#
	#modulate = Color(1,1,1)
#
#
#func _on_gui_input(event):
#
	#if event is InputEventMouseButton:
#
		#if event.button_index == MOUSE_BUTTON_LEFT:
#
			#if event.pressed:
#
				#print(
					#"Selected enemy:",
					#enemy.name
				#)
#
				#GameEvents.target_selected.emit(
					#enemy
				#)


func update_hp(
	current_hp:int,
	max_hp:int
):

	hp_bar.max_value = max_hp
	hp_bar.value = current_hp


func update_status():

	if enemy == null:
		return

	var text := ""

	for status in enemy.status_effects:

		text += (
			status.get_display_text()
			+ "\n"
		)

	status_label.text = text
