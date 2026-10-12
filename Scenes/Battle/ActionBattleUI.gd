extends CanvasLayer
class_name ActionBattleUI


# ==================================================
# References
# ==================================================

var player: CharacterBody3D
var deebo: CharacterBody3D

var combat_controller: ActionCombatController3D


# ==================================================
# UI
# ==================================================

@onready var deebo_hp: ProgressBar = $UI/DeeboHP
@onready var player_hp: ProgressBar = $UI/PlayerHP

@onready var move_1_name: Label = $UI/Move1/MarginContainer/VBoxContainer/Name
@onready var move_2_name: Label = $UI/Move2/MarginContainer/VBoxContainer/Name
@onready var move_3_name: Label = $UI/Move3/MarginContainer/VBoxContainer/Name

@onready var move_1_cooldown: Label = $UI/Move1/MarginContainer/VBoxContainer/Cooldown
@onready var move_2_cooldown: Label = $UI/Move2/MarginContainer/VBoxContainer/Cooldown
@onready var move_3_cooldown: Label = $UI/Move3/MarginContainer/VBoxContainer/Cooldown


# ==================================================
# Setup
# ==================================================

func setup(
	player_ref: CharacterBody3D,
	deebo_ref: CharacterBody3D,
	controller_ref: ActionCombatController3D = null
) -> void:

	player = player_ref
	deebo = deebo_ref
	combat_controller = controller_ref

	if player == null:
		push_error("ActionBattleUI: Player reference is missing.")
		return

	if deebo == null:
		push_error("ActionBattleUI: Deebo reference is missing.")
		return

	# Player health
	if player.has_signal("health_changed"):
		if not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)

	player_hp.max_value = player.max_health
	player_hp.value = player.current_health

	# Deebo health
	if deebo.has_signal("health_changed"):
		if not deebo.health_changed.is_connected(_on_deebo_health_changed):
			deebo.health_changed.connect(_on_deebo_health_changed)

	deebo_hp.max_value = deebo.max_health
	deebo_hp.value = deebo.current_health


# ==================================================
# Health Connections
# ==================================================

func _ready() -> void:

	pass


func _process(_delta: float) -> void:

	if combat_controller == null:
		return

	_update_cooldown_label(move_1_cooldown, &"bite")
	_update_cooldown_label(move_3_cooldown, &"gene_move")


func _update_cooldown_label(
	label: Label,
	move_name: StringName
) -> void:

	var remaining := combat_controller.get_move_cooldown_remaining(
		move_name
	)

	label.visible = remaining > 0.0
	label.text = "%.1f" % remaining if remaining > 0.0 else ""


# ==================================================
# Health Updates
# ==================================================

func _on_player_health_changed(
	current_health: float,
	maximum_health: float
) -> void:

	player_hp.max_value = maximum_health
	player_hp.value = current_health


func _on_deebo_health_changed(
	current_health: float,
	maximum_health: float
) -> void:

	deebo_hp.max_value = maximum_health
	deebo_hp.value = current_health


#func _on_animal_hp_changed(
	#animal: AnimalBase,
	#current_hp: int,
	#maximum_hp: int
#) -> void:
#
	#if animal != deebo:
		#return
#
	#deebo_hp.max_value = maximum_hp
	#deebo_hp.value = current_hp
#
#
## ==================================================
## Move Names
## ==================================================
#
#func update_move_names() -> void:
#
	#if deebo == null:
		#return
#
	#if not deebo.has_method("get_battle_moves"):
		#return
#
	#var moves = deebo.get_battle_moves()
#
	#var name_labels = [
		#move_1_name,
		#move_2_name,
		#move_3_name
	#]
#
	#for i in range(name_labels.size()):
#
		#if i < moves.size() and moves[i] != null:
#
			#name_labels[i].text = moves[i].move_name.to_upper()
#
		#else:
#
			#name_labels[i].text = ""
#
#
#func _on_move_cooldown_changed(
	#move: MoveResource,
	#remaining: float
#) -> void:
#
	#var moves = deebo.get_battle_moves()
#
	#var cooldown_labels = [
		#move_1_cooldown,
		#move_2_cooldown,
		#move_3_cooldown
	#]
#
	#for i in range(moves.size()):
#
		#if moves[i] != move:
			#continue
#
		#if remaining > 0.0:
#
			#cooldown_labels[i].text = "%.1f" % remaining
			#cooldown_labels[i].visible = true
#
		#else:
#
			#cooldown_labels[i].text = ""
			#cooldown_labels[i].visible = false
#
		#return
