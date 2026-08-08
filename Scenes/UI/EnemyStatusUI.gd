extends VBoxContainer
class_name EnemyStatusUI


# ==================================================
# UI References
# ==================================================

@onready var name_label = $NameLabel
@onready var hp_bar = $HPBar
@onready var status_label = $StatusLabel


# ==================================================
# Enemy
# ==================================================

var enemy: EnemyAnimal


# ==================================================
# Setup
# ==================================================


func setup(enemy_ref: EnemyAnimal):

	enemy = enemy_ref

	name_label.text = enemy.get_display_name()

	# ==========================================
	# HP
	# ==========================================

	update_hp(
		enemy.hp,
		enemy.get_max_hp()
	)

	# ==========================================
	# Status Effects
	# ==========================================

	status_label.text = ""

	if not enemy.status_changed.is_connected(update_status):
		enemy.status_changed.connect(update_status)

	update_status()


# ==================================================
# HP Updates
# ==================================================


func update_hp(
	current_hp: int,
	max_hp: int
):

	hp_bar.max_value = max_hp
	hp_bar.value = current_hp


# ==================================================
# Status Updates
# ==================================================


func update_status(_animal = null):

	if enemy == null:
		return

	var text := ""

	for status in enemy.status_effects:

		text += (
			status.get_display_text()
			+ "\n"
		)

	status_label.text = text
