extends VBoxContainer
class_name EnemyStatusUI


@onready var name_label = $NameLabel
@onready var hp_bar = $HPBar
@onready var status_label = $StatusLabel

var enemy: EnemyAnimal


func setup(enemy_ref:EnemyAnimal):

	enemy = enemy_ref

	name_label.text = enemy.get_display_name()

	hp_bar.max_value = enemy.get_max_hp()
	hp_bar.value = enemy.hp

	status_label.text = ""


func update_hp(
	current_hp:int,
	max_hp:int
):

	hp_bar.max_value = max_hp
	hp_bar.value = current_hp


func update_status():

	var text := ""

	for status in enemy.status_effects:

		text += (
			status.effect_name
			+ " x"
			+ str(status.stacks)
			+ "\n"
		)

	status_label.text = text
